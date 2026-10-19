function distance = euclidean(x, y, lowerBound, upperBound)
%EUCLIDEAN Pairwise Euclidean distance with optional bound normalization.
%
% The GSA-SLPSO diversity selection described in the manuscript calculates
% distances after normalizing each decision variable to its search bounds.

if nargin >= 4
    lowerBound = reshape(lowerBound, 1, []);
    upperBound = reshape(upperBound, 1, []);
    scale = upperBound - lowerBound;
    scale(scale == 0) = 1;
    x = (x - lowerBound) ./ scale;
    y = (y - lowerBound) ./ scale;
end

distanceSquared = sum(x.^2, 2) + sum(y.^2, 2)' - 2 * (x * y');
distance = sqrt(max(distanceSquared, 0));
end
