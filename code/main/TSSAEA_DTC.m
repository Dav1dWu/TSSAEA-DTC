function [historyX, historyF, evaluations, maxEvaluations, ...
    exactRecord, bestRecord, bestPointRecord, evaluationSource, ...
    improvementSource] = TSSAEA_DTC( ...
    objectiveFunction, dimension, lowerBound, upperBound, ...
    initialDatabase, parameters)
%TSSAEA_DTC Public controller of the TSSAEA-DTC framework.
%
% The controller follows Algorithm 1 in the associated manuscript. It owns
% the evaluated database, exact-simulation budget, best-so-far records, and
% dynamic transition criterion. The GSA-SLPSO and SA-MPDE strategy bodies
% are linked as external method modules and are not defined in this file.
%
% objectiveFunction returns a value to be minimized. For reservoir cases,
% the public objective interface returns negative NPV, which is equivalent
% to maximizing the NPV used in the manuscript.

if nargin < 6 || isempty(parameters)
    parameters = algorithm_parameters(dimension);
end

lowerBound = reshape(lowerBound, 1, []);
upperBound = reshape(upperBound, 1, []);
assert(size(initialDatabase, 2) == dimension + 1, ...
    'TSSAEA_DTC:InitialDatabase', ...
    'The initial database must contain D variables and one objective value.');
assert(size(initialDatabase, 1) == parameters.initialSampleSize, ...
    'TSSAEA_DTC:InitialSampleSize', ...
    'The manuscript configuration requires %d initial samples.', ...
    parameters.initialSampleSize);
assert(numel(lowerBound) == dimension && numel(upperBound) == dimension, ...
    'TSSAEA_DTC:Bounds', 'Bounds must match the decision dimension.');

maxEvaluations = parameters.maxEvaluations;
recordInterval = parameters.recordInterval;
historyX = initialDatabase(:, 1:dimension);
historyF = initialDatabase(:, dimension + 1).';
evaluations = size(historyX, 1);
assert(evaluations <= maxEvaluations, 'TSSAEA_DTC:Budget', ...
    'The initial database exceeds the exact-evaluation budget.');

exactRecord = nan(maxEvaluations, 2);
evaluationSource = zeros(1, maxEvaluations);
improvementSource = zeros(1, maxEvaluations);
recordCount = ceil(maxEvaluations / recordInterval);
bestRecord = nan(1, recordCount);
bestPointRecord = nan(recordCount, dimension);

[bestValue, bestIndex] = min(historyF);
bestPoint = historyX(bestIndex, :);
for index = 1:evaluations
    exactRecord(index, :) = [index, historyF(index)];
    if mod(index, recordInterval) == 0
        recordIndex = index / recordInterval;
        [recordBest, recordBestIndex] = min(historyF(1:index));
        bestRecord(recordIndex) = recordBest;
        bestPointRecord(recordIndex, :) = historyX(recordBestIndex, :);
    end
end

activeStrategy = parameters.initialStrategy; % 1: GSA-SLPSO, 2: SA-MPDE
failureCount = 0;
globalState = struct();
localState = struct();

while evaluations < maxEvaluations
    % Equations (17)-(18): the threshold decreases with the remaining
    % exact-simulation budget. A switch is applied before the next strategy
    % call, as specified by Algorithm 1.
    remainingFraction = (maxEvaluations - evaluations) / maxEvaluations;
    failureThreshold = parameters.transition.minimumFailures + ...
        remainingFraction * (parameters.transition.maximumFailures - ...
        parameters.transition.minimumFailures);
    if failureCount >= failureThreshold
        activeStrategy = 3 - activeStrategy;
        failureCount = 0;
    end

    bestBeforeStrategy = bestValue;
    remainingBudget = maxEvaluations - evaluations;
    if activeStrategy == 1
        [candidateBatch, globalState] = GSA_SLPSO_core( ...
            historyX, historyF, lowerBound, upperBound, globalState, ...
            parameters.global, remainingBudget);
    else
        [candidateBatch, localState] = SA_MPDE_core( ...
            historyX, historyF, lowerBound, upperBound, localState, ...
            parameters.local, remainingBudget);
    end

    assert(~isempty(candidateBatch) && ...
        mod(numel(candidateBatch), dimension) == 0, ...
        'TSSAEA_DTC:CandidateBatch', ...
        'The active strategy must return one or more D-dimensional candidates.');
    candidateBatch = reshape(candidateBatch, [], dimension);
    candidateBatch = min(upperBound, max(lowerBound, candidateBatch));
    candidateBatch = candidateBatch(1:min(size(candidateBatch, 1), ...
        remainingBudget), :);

    acceptedCandidates = zeros(0, dimension);
    for candidateIndex = 1:size(candidateBatch, 1)
        candidate = candidateBatch(candidateIndex, :);
        referencePoints = [historyX; acceptedCandidates];
        nearestDistance = min(euclidean(candidate, referencePoints, ...
            lowerBound, upperBound));
        if nearestDistance > parameters.duplicateTolerance
            acceptedCandidates(end + 1, :) = candidate; %#ok<AGROW>
        end
    end
    assert(~isempty(acceptedCandidates), 'TSSAEA_DTC:DuplicateBatch', ...
        'The active strategy returned no previously unevaluated candidate.');

    candidateValues = objectiveFunction(acceptedCandidates);
    candidateValues = reshape(candidateValues, 1, []);
    validateattributes(candidateValues, {'double'}, ...
        {'vector', 'real', 'finite', 'numel', size(acceptedCandidates, 1)}, ...
        mfilename, 'objective values');

    for candidateIndex = 1:size(acceptedCandidates, 1)
        candidate = acceptedCandidates(candidateIndex, :);
        candidateValue = candidateValues(candidateIndex);
        evaluations = evaluations + 1;
        historyX(end + 1, :) = candidate; %#ok<AGROW>
        historyF(end + 1) = candidateValue; %#ok<AGROW>
        exactRecord(evaluations, :) = [evaluations, candidateValue];
        evaluationSource(evaluations) = activeStrategy;

        if candidateValue < bestValue
            bestValue = candidateValue;
            bestPoint = candidate;
            improvementSource(evaluations) = activeStrategy;
        end

        if mod(evaluations, recordInterval) == 0
            recordIndex = evaluations / recordInterval;
            bestRecord(recordIndex) = bestValue;
            bestPointRecord(recordIndex, :) = bestPoint;
        end
    end

    % FN is updated once after the complete active-strategy call, matching
    % the strategy-level update in Algorithm 1.
    if bestValue < bestBeforeStrategy
        failureCount = 0;
    else
        failureCount = failureCount + 1;
    end
end

lastRecord = floor(evaluations / recordInterval);
bestRecord = bestRecord(1:lastRecord);
bestPointRecord = bestPointRecord(1:lastRecord, :);
exactRecord = exactRecord(1:evaluations, :);
evaluationSource = evaluationSource(1:evaluations);
improvementSource = improvementSource(1:evaluations);
end
