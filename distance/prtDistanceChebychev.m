function D = prtDistanceChebychev(varargin)
% prtDistanceChebychev    Chebychev distance
% 
%    DIST = prtDistanceChebychev(P1,P2) Calculates the distance from all of
%    the points in P1 to all of the points in P2 usuing the Chebychev
%    distance measure. The Chebychev distance is the maximum absolute
%    distance between any dimension of P1 and the corresponding of P2.
%
%    P1 should be an NxM matrix of locations, where N is the number of 
%    points and M is the dimensionality. P2 should be an DxM matrix of
%    locations. D is the number of points and M is the dimensionality. The
%    output DIST is an NxD matrix of distances.
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   DIST = prtDistanceChebychev(X,Y)
%
% See also: prtDistance, prtDistanceCityBlock, prtDistanceEuclidean,
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceLnorm

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

D = prtDistanceCustom(varargin{1},varargin{2},@(x1,x2)max(abs(x1-x2)));