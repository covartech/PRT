function D = prtDistanceLNorm(X1,X2,normMetric)
% LNORM     Calculate the distance from all of the points in P1 to all
%   of the points in P2 usuing the lnorm distance measure. The 
%   lnorm distance is the lnorm of the vectors P1 and P2. See norm.m
%
% Syntax: D = lnorm(varargin)
%
% Inputs: 
%   varargin{1} - double Mat - NxM matrix of locations. N is the number of 
%       points and M is the dimensionality.
%   varargin{2} - double Mat - DxM matrix of locations. D is the number of 
%       points and M is the dimensionality.
%   varargin{3} - int - The value of L to use for the lnorm.
%
% Outputs
%   D - NxD matrix of distances.
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   D = lnorm(X,Y,3)
%   
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: distance.m chebychev.m cityblock.m euclidean.m mahalanobis.m
%   squaredist.m

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 17-December-2005
% Last revision: 5-January-2006

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A subsection of IPDM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Used to handle memory efficiency paths see IPDM
chunkSize = 2^25;

[nSamples1, nDim1] = size(X1);
[nSamples2, nDim2] = size(X2);

if nDim1 ~= nDim2
    error('Dimensionality of X1 and X2 must be equal')
end

persistent bsxFunExists
if isempty(bsxFunExists)
    bsxFunExists = exist('bsxfun','builtin') || exist('bsxfun','file');
end
if bsxFunExists
    % We can use bsxfun
    if (nDim1>1) && ((nSamples1*nSamples2*nDim1)<=chunkSize)
        % its a small enough problem that we might gain by full use of bsxfun
        switch normMetric
            case 1
                D = sum(abs(bsxfun(@minus,reshape(X1,[nSamples1,1,nDim1]),reshape(X2,[1,nSamples2,nDim1]))),3);
            case inf
                D = max(abs(bsxfun(@minus,reshape(X1,[nSamples1,1,nDim1]),reshape(X2,[1,nSamples2,nDim1]))),[],3);
            case 0
                D = min(abs(bsxfun(@minus,reshape(X1,[nSamples1,1,nDim1]),reshape(X2,[1,nSamples2,nDim1]))),[],3);
            otherwise
                D = sum(bsxfun(@minus,reshape(X1,[nSamples1,1,nDim1]),reshape(X2,[1,nSamples2,nDim1])).^normMetric,3);
        end
    else
        % too big, so that the ChunkSize will have been exceeded, or just 1-d
        if isfinite(normMetric) && normMetric > 1
            D = bsxfun(@minus,X1(:,1),X2(:,1)').^normMetric;
        else
            D = abs(bsxfun(@minus,X1(:,1),X2(:,1)'));
        end
        for i=2:nDim1
            switch normMetric
                case 1
                    D = D + abs(bsxfun(@minus,X1(:,i),X2(:,i)'));
                case inf
                    D = max(D,abs(bsxfun(@minus,X1(:,i),X2(:,i)')));
                case 0
                    D = min(D,abs(bsxfun(@minus,X1(:,i),X2(:,i)')));
                otherwise
                    D = D + bsxfun(@minus,X1(:,i),X2(:,i)').^normMetric;
            end
        end
    end
else
    % Cannot use bsxfun. Sigh. Do things the hard (and slower) way.
    if isfinite(normMetric) && normMetric > 1
        D = (repmat(X1(:,1),1,nSamples2) - repmat(X2(:,1)',nSamples1,1)).^normMetric;
    else
        D = abs(repmat(X1(:,1),1,nSamples2) - repmat(X2(:,1)',nSamples1,1));
    end
    for i=2:nDim1
        switch normMetric
            case 1
                D = D + abs(repmat(X1(:,i),1,nSamples2) - repmat(X2(:,i)',nSamples1,1));
            case inf
                D = max(D,abs(repmat(X1(:,i),1,nSamples2) - repmat(X2(:,i)',nSamples1,1)));
            case 0
                D = min(D,abs(repmat(X1(:,i),1,nSamples2) - repmat(X2(:,i)',nSamples1,1)));
            otherwise
                D = D + (repmat(X1(:,i),1,nSamples2) - repmat(X2(:,i)',nSamples1,1)).^normMetric;
        end
    end
end

if isfinite(normMetric) && normMetric > 1
    if normMetric == 2
        D = sqrt(D);
    else
        D = D.^(1./normMetric);
    end
end

