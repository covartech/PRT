function D = prtDistanceCityBlock(varargin)
% CITYBLOCK      Calculate the distance from all of the points in P1 to all
%   of the points in P2 usuing the cityblock distance measure. The
%   cityblock distance is the sum of the absolute distances between each of
%   the dimensions of P1 and P2.
%
% Syntax: D = cityblock(varargin)
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
%   D = dprtDistanceCityBlock(X,Y)
%   
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: distance.m chebychev.m euclidean.m lnorm.m mahalanobis.m
%   squaredist.m

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

%D = prtDistanceCustom(varargin{1},varargin{2},@(x1,x2)sum(abs(x1-x2)));

nDims = size(varargin{1},2);

for iDim = 1:nDims
    cD = prtDistanceLNorm(varargin{1}(:,iDim),varargin{2}(:,iDim),1);
    if iDim == 1
        D = cD;
    else
        D = D + cD;
    end
end 