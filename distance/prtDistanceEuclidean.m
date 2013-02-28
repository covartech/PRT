function D = prtDistanceEuclidean(dataSet1,dataSet2)
%prtDistanceEuclidean   Euclidean distance
%   
%   DIST = prtDistanceCityBlock(DS1,DS2) calculates the Euclidean distance
%   from all the observations in datasets DS1 to DS2, and ouputs a distance
%   matrix of size DS1.nObservations x DS2.nObservations. DS1 and DS2
%   should have the same number of features. DS1 and DS2 should be
%   prtDataSet objects.
%   
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Euclidean_distance
%
% Example:
%
%   % Create 2 data sets
%   dsx = prtDataSetStandard('Observations', [0 0; 1 1]);
%   dsy = prtDataSetStandard('Observations', [1 0;2 2; 3 3]);
%   % Compute distance
%   distance = prtDistanceEuclidean(dsx,dsy)
%
% See also: prtDistanceCityBlock, prtDistanceChebychev
% prtDistanceMahalanobis, prtDistanceSquare, prtDistanceLnorm

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);
D = prtDistanceLNorm(data1,data2,2);
