function [scaledSamples, normalizedSamples] = lhsdesign_modified( ...
    sampleCount, lowerBound, upperBound)
%LHSDESIGN_MODIFIED Scale a Latin-hypercube design to supplied bounds.
%
% Inputs
%   sampleCount - number of sample points
%   lowerBound  - lower bound for each variable
%   upperBound  - upper bound for each variable
%
% Outputs
%   scaledSamples     - samples inside the supplied variable bounds
%   normalizedSamples - samples inside the unit hypercube

lowerBound = lowerBound(:);
upperBound = upperBound(:);
dimension = numel(lowerBound);
assert(numel(upperBound) == dimension, ...
    'lhsdesign_modified:DimensionMismatch', ...
    'Lower and upper bounds must have equal dimensions.');

scale = (upperBound - lowerBound)';
offset = lowerBound';
normalizedSamples = lhsdesign(sampleCount, dimension);
scaledSamples = normalizedSamples .* repmat(scale, sampleCount, 1) + ...
    repmat(offset, sampleCount, 1);
end
