function D = prtDistanceMahalanobis(dataSet1,dataSet2,covar)
% prtDistanceMahalanobis   Mahalanobis distance.
%
%   dist = prtDistanceMahalanobis(d1,d2) for data sets or double matrices d1
%   and d2 calculates the Mahalanobis distance from all the observations in
%   d1 to d2, and ouputs a distance matrix of size d1.nObservations x
%   d2.nObservations (size(d1,1) x size(d2,1) for double matrices).  The
%   covariance matrix in the Mahalanobis is estimated from both the data in
%   dataSet1 and dataSet2.
%  
%   d1 and d2 should have the same dimensionality, i.e. d1.nFeatures ==
%   d2.nFeatures (size(d1,2) == size(d2,2) for double matrices).
%
%   dist = prtDistanceMahalanobis(d1,d2,covar) specifies the covariance
%   matrix to use.
%   
% Example:
%   
%   X = [0 0; 1 1];
%   Y = [1 0; 2 2; 3 3;];
%   covMat = [1 0; 0 2;];
%   D = prtDistanceMahalanobis(X,Y,covMat)
%
%   For more information, see:
%   http://en.wikipedia.org/wiki/Mahalanobis_distance
%
% See also: prtDistance, prtDistanceCityBlock, prtDistanceLNorm,
% prtDistanceEuclidean, prtDistanceSquare, prtDistanceChebychev

% Copyright 2010, New Folder Consulting, L.L.C.

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
if nargin < 3
    covar = cov(cat(1,data1,data2));
end
D = prtDistanceCustom(data1,data2,@(x1,x2)(x1-x2)*(covar\(x1-x2)'));