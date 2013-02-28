function y = prtRvUtilDiscreteRnd(values,probabilities,N,discreteEps)
%y = discreternd(values,probabilities,N);
%	Draw N RV's from a multi-variate uniform distribution with limits
%	LIMS.

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
    N = 1;
end
if nargin < 4
    discreteEps = 1e-6;
end

if isa(values,'double')
    if isscalar(N)
        y = nan(N,1);
    else
        y = nan(N);
    end
elseif isa(values,'cell');
    if isscalar(N)
        y = cell(N,1);
    else
        y = cell(N);
    end
else
    if isscalar(N)
        y = nan(N,1);
    else
        y = nan(N);
    end
end
PROBS = cumsum(probabilities);
if max(PROBS) > 1 + discreteEps
    error('Invalid probability vector');
end
for i = 1:numel(y)
    x = rand;
    I = find(x < PROBS);
    I = I(1);
    if isa(values,'double')
        y(i) = values(I);
    elseif isa(values,'cell');
        y{i} = values{I};
    else %handle classes:
        if i == 1
            y = values(I);
        else
            y(i) = values(I);
        end
    end
end
