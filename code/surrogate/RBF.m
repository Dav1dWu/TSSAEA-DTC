function [lambda, gamma] = RBF(samples, values, basisType)
%RBF Fit the Gaussian RBFN formulation described in the manuscript.
%
% samples is an N-by-D matrix and values is an N-by-1 vector. The Gaussian
% shape parameter is calculated from the maximum pairwise sample distance:
% rho = dmax / (D*N)^(1/D).

if nargin < 3 || isempty(basisType)
    basisType = 'Gaussian';
end
assert(strcmpi(basisType, 'Gaussian'), 'RBF:BasisType', ...
    'The manuscript configuration uses the Gaussian RBFN kernel.');

[sampleCount, dimension] = size(samples);
values = reshape(values, [], 1);
assert(numel(values) == sampleCount, 'RBF:ValueCount', ...
    'One response value is required for each training sample.');

distance = euclidean(samples, samples);
maximumDistance = max(distance, [], 'all');
rho = maximumDistance / (dimension * sampleCount)^(1 / dimension);
if ~isfinite(rho) || rho <= 0
    rho = 1;
end

phi = exp(-(distance.^2) / rho^2);
polynomial = [samples, ones(sampleCount, 1)];
systemMatrix = [phi, polynomial; ...
    polynomial', zeros(dimension + 1, dimension + 1)];
rightHandSide = [values; zeros(dimension + 1, 1)];
parameters = systemMatrix \ rightHandSide;
lambda = parameters(1:sampleCount);
gamma = parameters(sampleCount + 1:end);
end
