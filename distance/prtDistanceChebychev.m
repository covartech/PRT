function D = prtDistanceChebychev(dataSet1,dataSet2)
% prtDistanceChebychev    Chebychev distance
% 
%   DIST = prtDistanceChebychev(DS1,DS2) calculates the Chebychev distance
%   from all the observations in datasets DS1 to DS2, and ouputs a distance
%   matrix of size DS1.nObservations x DS2.nObservations. DS1 and DS2
%   should have the same number of features. DS1 and DS2 should be
%   prtDataSet objects.
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
%   distance = prtDistanceChebychev(dsx,dsy)
%
% See also:  prtDistanceCityBlock, prtDistanceEuclidean,
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceLnorm







[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
D = prtDistanceCustom(data1,data2,@(x1,x2)max(abs(x1-x2)));
