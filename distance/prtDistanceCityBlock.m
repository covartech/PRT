function D = prtDistanceCityBlock(p1,p2)
% prtDistanceCityBlock   City block distance
% 
%    DIST = prtDistanceCityBlock(P1,P2) Calculate the distance from all of
%    the points in P1 to all of the points in P2 usuing the cityblock
%    distance measure. The cityblock distance is the sum of the absolute
%    distances between each of the dimensions of P1 and P2.
% 
%   P1 is a  NxM matrix of locations. N is the number of points and M is
%   the dimensionality. P2 is a DxM matrix of locations. D is the number of
%   points and M is the dimensionality. The output DIST is a NxD matrix of
%   distances.
%
%
%    Example:
%      X = [0 0; 1 1];
%      Y = [1 0; 2 2; 3 3;];
%      D = prtDistanceCityBlock(X,Y)
%   
% See also: prtDistance, prtDistanceMahalanobis, prtDistanceLNorm.
% prtDistanceEuclidean, prtDistanceSquare, prtDistanceChebychev


% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

D = prtDistanceCustom(p1,p2,@(x1,x2)sum(abs(x1-x2)));

nDims = size(p1,2);

for iDim = 1:nDims
    cD = prtDistanceLNorm(p1(:,iDim),p2(:,iDim),1);
    if iDim == 1
        D = cD;
    else
        D = D + cD;
    end
end 