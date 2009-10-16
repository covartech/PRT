function D = prtDistanceEuclidean(varargin)
% EUCLIDEAN     Calculate the distance from all of the points in P1 to all
%   of the points in P2 usuing the euclidean distance measure. The 
%   euclidean distance is the same as the lnorm with parameter 2.
%
% Syntax: D = euclidean(varargin)
%
% Inputs: 
%   varargin{1} - double Mat - NxM matrix of locations. N is the number of 
%       points and M is the dimensionality.
%   varargin{2} - double Mat - DxM matrix of locations. D is the number of 
%       points and M is the dimensionality.
%
% Outputs
%   D - NxD matrix of distances.
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   D = euclidean(X,Y)
%   
% Other m-files required: lnorm
% Subfunctions: none
% MAT-files required: none
%
% See also: distance.m chebychev.m cityblock.m lnorm.m mahalanobis.m
%   squaredist.m

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

V1 = varargin{1};
V2 = varargin{2};

D = prtDistanceLNorm(V1,V2,2);