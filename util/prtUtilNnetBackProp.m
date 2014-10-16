function [weightCellOut,out] = prtUtilNnetBackProp(ds,weightCell,stepSize,fwdFn,fwdFnDeriv)
%[weightCell,out] = prtUtilNnetBackProp(ds,weightCell)
%[weightCell,out] = prtUtilNnetBackProp(ds,weightCell,stepSize)
%[weightCell,out] = prtUtilNnetBackProp(ds,weightCell,stepSize,fwdFn,fwdFnDeriv)
%   Perform back-propagation on the weights in weightCell, using the data
%   in ds, the appropriate stepSize and activation functions.  
%
%   Defaults:
%       stepSize = 0.1
%       fwdFn = @(x) 1./(1 + exp(-x));
%       fwdFnDeriv = @(x) fwdFn(x).*(1-fwdFn(x)); %true for sigmoid
%       
%
% Based on Duda, Hart, Stork, "Pattern Classification", 2nd Ed., Pages
% 291-293.
%
% Currently:
%  Does both forward and back-prop (should be separated)
%  Only valid for single-target column (e.g., binary classsification)
%  

% Copyright (c) 2014 CoVar Applied Technologies
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


sigmoidFn = @(x) 1./(1 + exp(-x));
if nargin < 3 || isempty(stepSize)
    stepSize = .1;
end
if nargin < 4 || isempty(fwdFn)
    fwdFn = sigmoidFn;
end
if nargin < 5 || isempty(fwdFnDeriv)
    fwdFnDeriv = @(x) sigmoidFn(x).*(1-sigmoidFn(x));
end

%Initialize output 
weightCellOut = weightCell;

% Forward run:
input = {ds.X};
n = size(input{1},1);

for i = 1:length(weightCell)
    net{i+1} = (input{i}*weightCell{i});
    input{i+1} = fwdFn(net{i+1});
    % Bias:
    input{i+1} = cat(2,ones(n,1),input{i+1});
end
% Remove bias from output
input{end} = input{end}(:,2:end);
out = input{end};

%Handle nan targets
if isempty(ds.targets)
    ds.targets = nan(n,1);
end

% Update last set of weights, see, Duda, Page 291

% for nn = 1:n
%     for k = 1
%         for j = 1:31
%             dwkj(nn,k,j) = stepSize*(eRaw(nn))*fwdFnDeriv(net{end}(nn))*input{end-1}(nn,j);
%         end
%     end
% end
eRaw = ds.targets-input{end};
deltaK = eRaw.*fwdFnDeriv(net{end});
dw = stepSize*bsxfun(@times,deltaK,input{end-1});

weightCellOut{end} = weightCellOut{end} + mean(dw)';

% Update first set of weights, see, Duda, Page 292

% for nn = 1:n
%     for i=1:3;
%         for j = 1:30
%             dwji(nn,j,i) = stepSize*(weightCell{end}(j+1)*deltaK(nn))*fwdFnDeriv(net{2}(nn,j))*input{1}(nn,i);
%         end
%     end
% end

inSize = size(input{1});
deltaJ = bsxfun(@times,weightCell{2}(2:end)',deltaK).*fwdFnDeriv(net{2});
dw = stepSize*bsxfun(@times,deltaJ,reshape(input{1},[inSize(1),1,inSize(2)]));
dw = squeeze(mean(dw));
weightCellOut{1} = weightCellOut{1} + dw';

% tic;
% for i = 1:size(input{1},2)
%     dw = stepSize*bsxfun(@times,deltaJ,input{1}(:,i));
%     weightCellOut{1}(i,:) = weightCellOut{1}(i,:) + mean(dw);
% end
% toc
