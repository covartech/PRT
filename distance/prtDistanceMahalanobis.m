function D = prtDistanceMahalanobis(varargin)
% prtDistanceMahalanobis   Mahalanobis distance.
%
%   DIST = prtDistanceMahalanobis(P1,P2, COV) Calculates the distance from all of the points in P1 to all
%   of the points in P2 usuing the Mahalanobis distance measure. The 
%   Mahalanobis distance is the exponent of the multivariate gaussian 
%   density function evaluated at the distance between vectors P1 and P2. 
%
%    P1 should be an NxM matrix of locations, where N is the number of 
%    points and M is the dimensionality. P2 should be an DxM matrix of
%    locations. D is the number of points and M is the dimensionality. COV
%    is the MxM covariance matrix. The output DIST is an NxD matrix of
%    distances.
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   covMat = [1 0; 0 2;];
%   D = prtDistanceMahalanobis(X,Y,covMat)
%
% See also: prtDistance, prtDistanceCityBlock, prtDistanceLNorm,
% prtDistanceEuclidean, prtDistanceSquare, prtDistanceChebychev

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

invCovMat = inv(varargin{3});
D = prtDistanceCustom(varargin{1},varargin{2},@(x1,x2)(x1-x2)*invCovMat*(x1-x2));