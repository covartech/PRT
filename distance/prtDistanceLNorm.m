function D = prtDistanceLNorm(dataSet1,dataSet2,Lnorm)
% prtDistanceLNorm   L Norm distance function.
%
%   dist = prtDistanceLNorm(d1,d2,Lnorm) for data sets or double matrices d1
%   and d2 calculates the Lnorm distance from all the observations in
%   d1 to d2, and ouputs a distance matrix of size d1.nObservations x
%   d2.nObservations (size(d1,1) x size(d2,1) for double matrices).
%  
%   d1 and d2 should have the same dimensionality, i.e. d1.nFeatures ==
%   d2.nFeatures (size(d1,2) == size(d2,2) for double matrices).
%   
%    Example:
%      X = [0 0; 1 1];
%      Y = [1 0; 2 2; 3 3;];
%      DIST = prtDistanceLNorm(X,Y,3)
%
%     % prtDistanceLNorm also accepts prtDataSet inputs:
%     dsx = prtDataSetStandard(X);
%     dsy = prtDataSetStandard(Y);
%     distance = prtDistanceLNorm(dsx,dsy);
%
%   For more information, see:
%
%   http://en.wikipedia.org/wiki/Norm_(mathematics)#p-norm
%
% See also: prtDistance, prtDistanceCityBlock, prtDistanceEuclidean,
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceChebychev, norm

% Copyright 2010, New Folder Consulting, L.L.C.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A subsection of IPDM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);

% Used to handle memory efficiency paths see IPDM
chunkSize = 2^25;

[nSamples1, nDim1] = size(data1);
[nSamples2, nDim2] = size(data2);

if nDim1 ~= nDim2
    error('Dimensionality of data1 and data2 must be equal')
end

if (nDim1>1) && ((nSamples1*nSamples2*nDim1)<=chunkSize)
    switch Lnorm
        case 1
            D = sum(abs(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1]))),3);
        case inf
            D = max(abs(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1]))),[],3);
        case 0
            D = min(abs(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1]))),[],3);
        case 2
            %un-rolled((x-y)^2)) - sqrt below; this takes less time than
            %the generic code below for the most common L-norm (2)
            
            %D = repmat(sum((data1.^2), 2), [1 nSamples2]) + repmat(sum((data2.^2),2), [1 nSamples1]).' - 2*data1*(data2.');
            D = bsxfun(@minus,bsxfun(@plus,sum((data1.^2), 2),sum((data2.^2),2).'),2*data1*(data2.'));
            
        otherwise
            D = sum(bsxfun(@minus,reshape(data1,[nSamples1,1,nDim1]),reshape(data2,[1,nSamples2,nDim1])).^Lnorm,3);
    end
else
    % too big, so that the ChunkSize will have been exceeded, or just 1-d
    if isfinite(Lnorm) && Lnorm > 1
        D = bsxfun(@minus,data1(:,1),data2(:,1)').^Lnorm;
    else
        D = abs(bsxfun(@minus,data1(:,1),data2(:,1)'));
    end
    for i=2:nDim1
        switch Lnorm
            case 1
                D = D + abs(bsxfun(@minus,data1(:,i),data2(:,i)'));
            case inf
                D = max(D,abs(bsxfun(@minus,data1(:,i),data2(:,i)')));
            case 0
                D = min(D,abs(bsxfun(@minus,data1(:,i),data2(:,i)')));
            otherwise
                D = D + bsxfun(@minus,data1(:,i),data2(:,i)').^Lnorm;
        end
    end
end

if isfinite(Lnorm) && Lnorm > 1
    if Lnorm == 2
        D = sqrt(D);
    else
        D = D.^(1./Lnorm);
    end
end

