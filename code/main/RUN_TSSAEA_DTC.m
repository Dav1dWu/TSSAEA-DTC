function [convergenceNPV, timeCost] = RUN_TSSAEA_DTC( ...
    runs, dimension, objectives, lowerBound, upperBound, caseName)
%RUN_TSSAEA_DTC Execute the ten independent manuscript runs.

startTime = tic;
load('preright.mat', 'xx1', 'xx2', 'xx3', 'xx4', 'xx5', ...
    'xx6', 'xx7', 'xx8', 'xx9', 'xx10');
initialDesigns = {xx1, xx2, xx3, xx4, xx5, xx6, xx7, xx8, xx9, xx10};
assert(runs == 10 && runs <= numel(initialDesigns), ...
    'RUN_TSSAEA_DTC:RunCount', ...
    'The manuscript configuration uses ten independent runs.');

parameters = algorithm_parameters(dimension);
convergenceNPV = cell(1, runs);
bestPoints = zeros(runs, dimension);
evaluatedDatabases = cell(1, runs);
evaluationSources = cell(1, runs);
improvementSources = cell(1, runs);

for runIndex = 1:runs
    fprintf('CASE: %s RUN: %d\n', caseName, runIndex);
    initialDatabase = initialDesigns{runIndex};
    assert(size(initialDatabase, 1) == parameters.initialSampleSize, ...
        'RUN_TSSAEA_DTC:InitialSampleSize', ...
        'Each initial database must contain 200 evaluated LHS samples.');

    [evaluatedX, evaluatedF, ~, ~, ~, bestRecord, ~, ...
        evaluationSource, improvementSource] = TSSAEA_DTC( ...
        objectives{runIndex}, dimension, lowerBound, upperBound, ...
        initialDatabase, parameters);

    [~, bestIndex] = min(evaluatedF);
    convergenceNPV{runIndex} = -bestRecord;
    bestPoints(runIndex, :) = evaluatedX(bestIndex, :);
    evaluatedDatabases{runIndex} = [evaluatedX, evaluatedF(:)];
    evaluationSources{runIndex} = evaluationSource;
    improvementSources{runIndex} = improvementSource;
end

timeCost = toc(startTime);
save(sprintf('Result_%s_TSSAEA_DTC_runs_%d.mat', caseName, runs), ...
    'convergenceNPV', 'bestPoints', 'evaluatedDatabases', ...
    'evaluationSources', 'improvementSources', 'timeCost', 'parameters');
end
