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
if nargin < 3
    covar = cov(cat(1,data1,data2));
end
D = prtDistanceCustom(data1,data2,@(x1,x2)(x1-x2)*(covar\(x1-x2)'));
