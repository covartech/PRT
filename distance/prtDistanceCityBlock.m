function D = prtDistanceCityBlock(dataSet1,dataSet2)
% prtDistanceCityBlock   City block distance
% 
%   DIST = prtDistanceCityBlock(DS1,DS2) calculates the City Block distance
%   from all the observations in datasets DS1 to DS2, and ouputs a distance
%   matrix of size DS1.nObservations x DS2.nObservations. DS1 and DS2
%   should have the same number of features. DS1 and DS2 should be
%   prtDataSet objects.
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Taxicab_geometry
%
% Example:
%
%   % Create 2 data sets
%   dsx = prtDataSetStandard('Observations', [0 0; 1 1]);
%   dsy = prtDataSetStandard('Observations', [1 0;2 2; 3 3]);
%   % Compute distance
%   distance = prtDistanceCityBlock(dsx,dsy)
%
% See also:  prtDistanceChebychev, prtDistanceEuclidean,
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceLnorm







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
