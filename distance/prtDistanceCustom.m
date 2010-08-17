function D = prtDistanceCustom(varargin)
% prtDistanceCustom   Custom distance function
% 
%   DIST = prtDistanceCustom(P1,P2,DISTFUN) returns the distance between P1
%   and P2, as calculated by the function DISTFUN. P1 should be an NxM
%   matrix of locations, where N is the number of points and M is the
%   dimensionality. P2 should be an DxM matrix of locations. D is the
%   number of points and M is the dimensionality. DISTFUN is a function
%   handle that points to a function that computes the distance. The output
%   DIST is an NxD matrix of distances.
%
%   prtDistanceCustom is a helper function and is not designed for general
%   purpose use.
%
%   See Also:  prtDistance prtDistanceChebychev prtDistanceCityBlock
%   prtDistanceEuclidean prtDistanceMahalanobis prtDistanceSquare


V1 = varargin{1};
V2 = varargin{2};
singleDistanceFunction = varargin{3};

D = zeros(size(V1,1),size(V2,1));
for i = 1:size(V1,1);
    for j = 1:size(V2,1);
        D(i,j) = feval(singleDistanceFunction,V1(i,:),V2(j,:));
    end
end