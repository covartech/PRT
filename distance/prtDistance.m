function D = prtDistance(X1,X2,distanceFunctionHandle, varargin)
% DISTANCE      Calculate the distance from all of the points in X1 to all
%   of the points in X2.
%
% Syntax: D = prtDistance(X1,X2,distanceFunctionHandle,varargin);
%
% Inputs:
%   X1 - double Mat - NxM matrix of locations. N is the number of points
%       and M is the dimensionality.
%   X2 - double Mat - DxM matrix of locations. D is the number of points
%       and M is the dimensionality.
%   distanceFunctionHandle - str - A function handle which specifies the
%       distance metric to use. Possibilites are as follows:
%           - 'chebychev'
%           - 'cityblock'
%           - 'euclidean'
%           - 'lnorm'
%           - 'mahalanobis'
%           - 'squaredist'
%   varargin - additional arguments necessary for the particular distance
%       function specified by distanceFunctionHandle.
%
% Outputs
%   D - NxD matrix of distances.
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   D = distance(X,Y,'euclidean')
%
% Other m-files required: dependent on distanceFunctionHandle
% Subfunctions: none
% MAT-files required: none
%
% See also: chebychev.m cityblock.m euclidean.m lnorm.m mahalanobis.m
%   squaredist.m
%
% The memory efficient formulation for this was taken from MATLAB Central
% submission IPDM.
%
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=18937

% Author: Kenneth D. Morton Jr.
% Created: 17-December-2005
% Last revision: 14-May-2008

if nargin < 2 || isempty(X2)
    X2 = X1; % This shouldn't hurt us memory wise because MATLAB is smart
    % enough not to copy it, and only make a pointer.
end

% Sanity check
if size(X1,2) ~= size(X2,2)
    error('prtDistance:dimensionality','X1 and X2 differ in dimensionality');
end

% Default to L2 ie Euclidean
if nargin < 3 || isempty(distanceFunctionHandle)
    distanceFunctionHandle = @(X1,X2)prtDistanceLNorm(X1,X2,2);
end

% String name and possibly extra args specified
if ischar(distanceFunctionHandle)
    extraArgs = varargin;
    switch lower(distanceFunctionHandle)
        case {'chebychev','prtdistancechebychev'}
            distanceFunctionHandle = @prtDistanceChebychev;
        case {'cityblock','prtdistancecityblock'}
            distanceFunctionHandle = @prtDistanceCityBlock;
        case {'euclidean','prtdistanceeuclidean'}
            distanceFunctionHandle = @prtDistanceEuclidean;
        case {'lnorm','prtdistancelnorm'}
            if ~isempty(extraArgs)
                normOrder = extraArgs{1};
            else
                normOrder = 2;
            end
            distanceFunctionHandle = @(X1,X2)prtDistanceLNorm(X1,X2,normOrder);
        case {'mahalanobis','prtdistancemahalanobis'}
            if ~isempty(extraArgs)
                sigma = extraArgs{1};
            else
                sigma = eye(size(X1,2));
            end
            distanceFunctionHandle = @(X1,X2)prtDistanceMahalanobis(X1,X2,sigma);
        case {'square','prtdistancesquare'}
            distanceFunctionHandle = @prtDistanceSquare;
        otherwise
            error('prtDistance:unknownDistanceFunction','Unknown distance method %s',distanceFunctionHandle);
    end
end

% Call the necessary function
D = feval(distanceFunctionHandle,X1,X2);
