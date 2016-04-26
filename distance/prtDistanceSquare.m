function D = prtDistanceSquare(dataSet1,dataSet2)
% prtDistanceSquare  Compute distance squared
%
%   DIST = prtDistanceChebychev(DS1,DS2) calculates the Distance square distance
%   from all the observations in datasets DS1 to DS2, and ouputs a distance
%   matrix of size DS1.nObservations x DS2.nObservations. DS1 and DS2
%   should have the same number of features. DS1 and DS2 should be
%   prtDataSet objects. This distance is the same as the Chebychev disance
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Chebyshev_distance
%
% Example:
%
%   % Create 2 data sets
%   dsx = prtDataSetStandard('Observations', [0 0; 1 1]);
%   dsy = prtDataSetStandard('Observations', [1 0;2 2; 3 3]);
%   % Compute distance
%   distance = prtDistanceSquare(dsx,dsy)
%
% See also:  prtDistanceCityBlock, prtDistanceEuclidean,
% prtDistanceMahalanobis, prtDistanceChebychev, prtDistanceLnorm







D = prtDistanceChebychev(dataSet1,dataSet2);
