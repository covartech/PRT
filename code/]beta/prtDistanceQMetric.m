function D = prtDistanceQMetric(dataSet1,dataSet2,lambda)

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


% D = prtDistanceQMetric(dataSet1,dataSet2,lambda)

if nargin < 3 || isempty(lambda)
    lambda = -0.4;
end

assert(lambda <= 0 && lambda >= -1,'lambda must be between -1 and 0');

[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2);

if any(data1(:)<0) || any(data1(:)>1) || any(data2(:)<0) || any(data2(:)>1)
    warning('prt:prtDistanceQMetric','prtDistanceQMetric should only be use for data with values in all dimensions between 0 and 1');
end

if lambda == 0
    D = prtDistanceLNorm(data1,data2,1);
    return
end

D = zeros(size(data1,1),size(data2,1));
for iDim = 1:size(data1,2)
    D = D + (1+lambda*D).*abs(bsxfun(@minus, data1(:,iDim),data2(:,iDim)'));
end
