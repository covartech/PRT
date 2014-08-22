function x = prtRvUtilRandomSample(probabilities, nSamples, population)
% prtRvUtilRandomSample - Draw from a population with specified probabilities
%
% x = prtRvUtilRandomSample(probabilities, nSamples, population)
% x = prtRvUtilRandomSample(nObjects, nSamples, population)

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



if numel(probabilities) == 1 % Assume nObjects
    assert(probabilities >= 1,'nObjects must be greater than or equal to 1');
    probabilities = 1./probabilities * ones(1,probabilities);
else
    if isempty(probabilities) && nargin > 2 && ~isempty(population)
        probabilities = ones(1,numel(population));
        probabilities = probabilities./sum(probabilities);
    end
    probabilities = probabilities(:)';
    assert(prtUtilApproxEqual(sum(probabilities),1,1e-6),'probabilities must sum to 1');
end

if nargin < 2 || isempty(nSamples)
    nSamples = 1;
end

[dontNeed, x] = histc(rand(nSamples,1),min([0 cumsum(probabilities)],1)); %#ok<ASGLU>

if nargin > 2
    x = population(x,:);
end
    
