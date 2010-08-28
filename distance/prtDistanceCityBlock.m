function D = prtDistanceCityBlock(dataSet1,dataSet2)
% prtDistanceCityBlock   City block distance
% 
%   dist = prtDistanceCityBlock(d1,d2) for data sets or double matrices d1
%   and d2 calculates the City block distance from all the observations in
%   d1 to d2, and ouputs a distance matrix of size d1.nObservations x
%   d2.nObservations (size(d1,1) x size(d2,1) for double matrices).
%  
%   d1 and d2 should have the same dimensionality, i.e. d1.nFeatures ==
%   d2.nFeatures (size(d1,2) == size(d2,2) for double matrices).
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Taxicab_geometry
%
%    Example:
%      X = [0 0; 1 1];
%      Y = [1 0; 2 2; 3 3;];
%      D = prtDistanceCityBlock(X,Y)
%   
% See also: prtDistance, prtDistanceMahalanobis, prtDistanceLNorm.
% prtDistanceEuclidean, prtDistanceSquare, prtDistanceChebychev

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
D = prtDistanceCustom(data1,data2,@(x1,x2)sum(abs(x1-x2)));

nDims = size(data1,2);

for iDim = 1:nDims
    cD = prtDistanceLNorm(data1(:,iDim),data2(:,iDim),1);
    if iDim == 1
        D = cD;
    else
        D = D + cD;
    end
end 