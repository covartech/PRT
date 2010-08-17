function D = prtDistanceLNorm(X1,X2,normMetric)
% prtDistanceLNorm   L Norm distance function.
%  
%   DIST = prtDistanceLNorm(X1,X2, NORMMETRIC) Calculate the distance from
%   all of the points in P1 to all of the points in P2 usuing the L Norm
%   distance measure. The L Norm distance is the L Norm of the vectors P1
%   and P2. 
% 
%   X1 is a  NxM matrix of locations. N is the number of points and M is
%   the dimensionality. X2 is a DxM matrix of locations. D is the number of
%   points and M is the dimensionality. NORMMETRIC Is the value of L to use
%   for the L Norm, and must be an integer. The output DIST - NxD matrix of
%   distances.
%
%    Example:
%      X = [0 0; 1 1];
%      Y = [1 0; 2 2; 3 3;];
%      DIST = prtDistanceLNorm(X,Y,3)
%   
%
% See also: prtDistance, prtDistanceCityBlock, prtDistanceEuclidean,
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceChebychev, norm

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

