function estimatedValues = RBF_eval( ...
    points, samples, lambda, gamma, basisType)
%RBF_EVAL Evaluate the Gaussian RBFN described in the manuscript.

if nargin < 5 || isempty(basisType)
    basisType = 'Gaussian';
end
assert(strcmpi(basisType, 'Gaussian'), 'RBF_eval:BasisType', ...
    'The manuscript configuration uses the Gaussian RBFN kernel.');

[~, sampleDimension] = size(samples);
if size(points, 2) ~= sampleDimension
    points = points';
end
assert(size(points, 2) == sampleDimension, ...
    'RBF_eval:DimensionMismatch', ...
    'Prediction points and training samples must have equal dimensions.');

trainingDistance = euclidean(samples, samples);
maximumDistance = max(trainingDistance, [], 'all');
sampleCount = size(samples, 1);
rho = maximumDistance / ...
    (sampleDimension * sampleCount)^(1 / sampleDimension);
if ~isfinite(rho) || rho <= 0
    rho = 1;
end

distance = euclidean(points, samples);
phi = exp(-(distance.^2) / rho^2);
estimatedValues = phi * lambda + ...
    [points, ones(size(points, 1), 1)] * gamma;
end
