function distance = prtDistanceEarthMover(dataSet1,dataSet2,X1,X2)
% prtDistanceEarthMover   Earth mover distance
%
%   DIST = prtDistanceEarthMover(DS1,DS2) calculates the Earth Mover
%   distance from all the observations in DS1 to DS2, and ouputs a distance
%   matrix of size DS1.nObservations x DS2.nObservations.  DS1 and DS2
%   should be prtDataSet objecgts. The covariance matrix in the Mahalanobis
%   is estimated from both the data in DS1 and DS2. DS1 and DS2 should have
%   the same number of features. prtDistanceEarthMover assumes that columns
%   represent weights for equally spaced points at locations
%   1:dataSet.nFeatures.
%   
%   Earth mover's distance requires that the values in d1 and d2 are
%   positive, and they should have constant row sums for the distance to be
%   meaningful.
%
%   DIST = prtDistanceEarthMover(DS1,DS2,X1,X2) where X1 and 
%   X2 are double matrices of size dataSet1.nObservations x
%   dataSet1.nFeatures and dataSet2.nObservations x dataSet2.nFeatures
%   allows the user to specify the locations of the points in each of the
%   data sets.
%
%   For more information, see:
%   
%   http://en.wikipedia.org/wiki/Earth_mover's_distance
%
%   See also: Rubner, Tomasi, Guibas.  The Earth Mover's Distance as a Metric
%   for Image Retrieval. 
%
%
%   Example:
%
%       d = rand(5,3);                    % Generate some random data
%       d = bsxfun(@rdivide,d,sum(d,2));   % Normalize
%
%       % Store data in prtDataSetStandard
%       DS = prtDataSetStandard('Observations',d);
%       % Compute distance
%       distance = prtDistanceEarthMover(DS,DS);
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


[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2,false);
if nargin < 4
    X1 = repmat(1:size(data1,2),size(data1,1),1);
    X2 = repmat(1:size(data2,2),size(data2,1),1);
end
if any(data1(:)) < 0 || any(data2(:)) < 0
    error('prt:prtDistanceEarthMover:InvalidWeights','prtDistanceEarthMover is only defined for data with values > 0');
end
if length(unique(sum(cat(1,data1,data2),2))) ~= 1
    warning('prt:prtDistanceEarthMover:InvalidWeights','prtDistanceEarthMover best defined for data whose rows sum to a constant value - length(unique(sum(data,2))) should be 1 (i.e. normalized histograms)');
end

opts1= optimset('display','off');

distance = zeros(size(data1,1),size(data2,1));
for i = 1:size(data1,1)
    for j = 1:size(data2,1)
        x1 = X1(i,:)';
        x2 = X2(j,:)';
        w1 = data1(i,:)';
        w2 = data2(j,:)';
        
        f = prtDistanceEuclidean(x1,x2);
        f = f';
        f = f(:);
        
        A = kron(eye(size(x1,1)),ones(1,size(x2,1)));
        A = cat(1,A,kron(ones(1,size(x1,1)),eye(size(x2,1))));
        b = [w1(:); w2(:)];
        
        Aeq = ones(size(f));
        beq = min([sum(w1),sum(w2)]);
        
        [~,distance(i,j)] = linprog(f,A,b,Aeq',beq,zeros(size(f)),[],[],opts1);
    end
end
