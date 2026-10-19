%RUN_THREECHANNEL Configure the manuscript Three-Channel experiment.
%
% The settings follow the 130-dimensional case reported in the manuscript.

clc;
clear;
repositoryRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(repositoryRoot));

testName = 'ThreeChannel';
runs = 10;
numWells = 13;
numSteps = 10;
dimension = numWells * numSteps;

upperBound = repmat([repmat(6000, 1, 9), ...
    repmat(1500, 1, 4)], 1, numSteps);
lowerBound = repmat([repmat(3000, 1, 9), ...
    zeros(1, 4)], 1, numSteps);

stepLength = 180;
summaryRow = 17;
caseRoot = fullfile(repositoryRoot, 'three_channel', 'runs');

objectives = cell(1, runs);
for runIndex = 1:runs
    caseDirectory = fullfile(caseRoot, sprintf('run_%02d', runIndex));
    objectives{runIndex} = @(x) evaluate_three_channel_npv( ...
        x, caseDirectory, stepLength, summaryRow);
end

RUN_TSSAEA_DTC(runs, dimension, objectives, ...
    lowerBound, upperBound, testName);
