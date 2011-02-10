function D = prtDistanceEuclidean(dataSet1,dataSet2)
%prtDistanceEuclidean   Euclidean distance
%   
%   dist = prtDistanceEuclidean(d1,d2) for data sets or double matrices d1
%   and d2 calculates the Euclidean distance from all the observations in
%   d1 to d2, and ouputs a distance matrix of size d1.nObservations x
%   d2.nObservations (size(d1,1) x size(d2,1) for double matrices).
%  
%   d1 and d2 should have the same dimensionality, i.e. d1.nFeatures ==
%   d2.nFeatures (size(d1,2) == size(d2,2) for double matrices).
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Euclidean_distance
%
% Example:
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   D = prtDistanceEuclidean(X,Y)
%   
%   % prtDistanceEuclidean also accepts prtDataSet inputs:
%   dsx = prtDataSetStandard(X);
%   dsy = prtDataSetStandard(Y);
%   distance = prtDistanceEuclidean(dsx,dsy);
%
% See also: prtDistance, prtDistanceCityBlock, prtDistanceLNorm.
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceChebychev

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
D = prtDistanceLNorm(data1,data2,2);