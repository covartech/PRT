function DataSet = prtDataGenSubspace(subspaceH1,subspaceH0,N)
%[X,Y] = prtDataGenSubspace(subspaceH1,subspaceH0,N)
%   Generate X data spanned by the subspace defined by the *columns* of
%   subspaceH1 and subspaceH0.  Each row of X is defined via
%       X(i,:) = subspace * \theta
%   Where each element of \theta is uniformly distributed.

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



if nargin < 3
    N = 400;
end

subspaceH1 = subspaceH1';
subspaceH0 = subspaceH0';

X1 = zeros(N,size(subspaceH1,2));
X0 = zeros(N,size(subspaceH0,2));
for i = 1:N;
    X1(i,:) = subspaceH1*rand(size(subspaceH1,1),1);
    X0(i,:) = subspaceH0*rand(size(subspaceH0,1),1);
end
X = cat(1,X0,X1);
Y = prtUtilY(N,N);

DataSet = prtDataSetClass(X,Y,'dataSetName','prtDataGenSubspace');
