function D = prtDistanceEuclidean(V1, V2)
%prtDistanceEuclidean   Euclidean distance
%   
%   DIST = prtDistanceEuclidean(X1,X2) Calculates the Euclidean distance from all of the points in P1 to all
%   of the points in P2.
%
%   X1 is a  NxM matrix of locations. N is the number of points and M is
%   the dimensionality. X2 is a DxM matrix of locations. D is the number of
%   points and M is the dimensionality. The output DIST is a NxD matrix of
%   distances.
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   D = prtDistanceEuclidean(X,Y)
%   
% See also: prtDistance, prtDistanceCityBlock, prtDistanceLNorm.
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceChebychev

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

D = prtDistanceLNorm(V1,V2,2);