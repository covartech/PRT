function D = prtDistanceMahalanobis(dataSet1,dataSet2,covar)
% prtDistanceMahalanobis   Mahalanobis distance.
%
%   DIST = prtDistanceMahalanobis(DS1,DS2) calculates the Mahalanobis
%   distance from all the observations in datasets DS1 to DS2, and ouputs a
%   distance matrix of size DS1.nObservations x DS2.nObservations.  The
%   covariance matrix in the Mahalanobis is estimated from both the data in
%   DS1 and DS2. DS1 and DS2 should have the same number of features. DS1
%   and DS2 should be prtDataSet objects.
%
%   DIST = prtDistanceMahalanobis(DS1,DS2, COVAR) specifies the covariance
%   matrix to use.
%
%   For more information on the Mahalanobis distance, see:
%   http://en.wikipedia.org/wiki/Mahalanobis_distance
%   
%  % Example:
%   
%  X = [0 0; 1 1];      % Create some data, store  in prtDataSetStandard
%  Y = [1 0; 2 2; 3 3;];
%  dsx = prtDataSetStandard(X);
%  dsy = prtDataSetStandard(Y);
%  covMat = [1 0; 0 2;];         % Specify the covariance matrix
%  % Compute the distance
%  distance = prtDistanceMahalanobis(dsx,dsy,covMat)
%
%
% See also: prtDistanceCityBlock, prtDistanceLNorm, prtDistanceEuclidean,
% prtDistanceSquare, prtDistanceChebychev








[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
if nargin < 3
    covar = cov(cat(1,data1,data2));
end
D = prtDistanceCustom(data1,data2,@(x1,x2)(x1-x2)*(covar\(x1-x2)'));
