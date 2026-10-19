function parameters = algorithm_parameters(dimension)
%ALGORITHM_PARAMETERS Parameters reported in the associated manuscript.

parameters.dimension = dimension;
parameters.initialSampleSize = 200;
parameters.maxEvaluations = 1000;
parameters.recordInterval = 1;
parameters.initialStrategy = 1; % 1: GSA-SLPSO, 2: SA-MPDE
parameters.duplicateTolerance = 1e-4;

% Dynamic transition criterion.
parameters.transition.minimumFailures = 3;
parameters.transition.maximumFailures = 20;

% GSA-SLPSO: the global surrogate uses all evaluated samples in DB.
parameters.global.method = 'GSA-SLPSO';
parameters.global.surrogate = 'Gaussian RBFN';
parameters.global.trainingPolicy = 'all evaluated samples';
parameters.global.populationSize = 100;

% SA-MPDE: the local surrogate uses the top-ranked samples in DB.
parameters.local.method = 'SA-MPDE';
parameters.local.surrogate = 'Gaussian RBFN';
parameters.local.trainingSize = 50;
parameters.local.populationSize = 50;
parameters.local.mutationFactor = 0.5;
parameters.local.crossoverRate = 0.5;
parameters.local.crossoverPopulationSize = 5;
parameters.local.crossoverCandidatePoolSize = 250;
end
