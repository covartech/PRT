function D = prtDistanceChebychev(dataSet1,dataSet2)
% prtDistanceChebychev    Chebychev distance
% 
%   dist = prtDistanceChebychev(d1,d2) for data sets or double matrices d1
%   and d2 calculates the Chebychev distance from all the observations in
%   d1 to d2, and ouputs a distance matrix of size d1.nObservations x
%   d2.nObservations (size(d1,1) x size(d2,1) for double matrices).
%  
%   d1 and d2 should have the same dimensionality, i.e. d1.nFeatures ==
%   d2.nFeatures (size(d1,2) == size(d2,2) for double matrices).
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Chebyshev_distance
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   dist = prtDistanceChebychev(X,Y)
%
% See also: prtDistance, prtDistanceCityBlock, prtDistanceEuclidean,
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceLnorm

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
D = prtDistanceCustom(data1,data2,@(x1,x2)max(abs(x1-x2)));