function D = prtDistanceMahalanobis(varargin)
% MAHALANOBIS    Calculate the distance from all of the points in P1 to all
%   of the points in P2 usuing the mahalanobis distance measure. The 
%   mahalanobis distance is the exponent of the multivariate gaussian 
%   density function evaluated at the distance between vectors P1 and P2. 
%
% Syntax: D = mahalanobis(varargin)
%
% Inputs: 
%   varargin{1} - double Mat - NxM matrix of locations. N is the number of 
%       points and M is the dimensionality.
%   varargin{2} - double Mat - DxM matrix of locations. D is the number of 
%       points and M is the dimensionality.
%   varargin{3} - double Mat - MxM covariance matrix.
%
% Outputs
%   D - NxD matrix of distances.
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   covMat = [1 0; 0 2;];
%   D = mahalanobis(X,Y,covMat)
% 
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: distance.m chebychev.m cityblock.m euclidean.m lnorm.m
%   squaredist.m

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

invCovMat = inv(varargin{3});
D = prtDistanceCustom(varargin{1},varargin{2},@(x1,x2)(x1-x2)*invCovMat*(x1-x2));