function gram = prtUtilRbfDist(x,y,varargin)

%   gram = rbfDistance(x,y,param1,value1,...)
%   finds the Radial Basis Function distance between X and Y.
%
%   gram = prtUtilRbfDist(x,y,param1,value1,...)
%   Enables inputs of parameter/value pairs as described below:
%
%   Parameters:
%       
%   sigma - Variance of the Radial Basis Function (RBF)
%
%   Example usage:
%
%   ds=prtDataGenUnimodal;
%   gram=prtUtilRbfDist(ds.X,ds.X,'sigma',1);
%   imagesc(gram)
%   title('X vs. Y Gram Matrix');
 
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

p = inputParser;

p.addParamValue('sigma',.2)

p.parse(varargin{:});
inputStruct = p.Results;
sigma=inputStruct.sigma;

[n1, d] = size(x);
[n2, nin] = size(y);

if d ~= nin
    error('size(x,2) must equal size(y,2)');
end

dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');

if numel(sigma) == 1
    gram = exp(-dist2/(sigma.^2));
else
    gram = exp(-bsxfun(@rdivide,dist2,(sigma.^2)'));
end

end