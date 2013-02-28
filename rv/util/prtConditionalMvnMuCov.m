function [condMu,condCov] = prtConditionalMvnMuCov(x,indices,globalMu,globalCov)
%[condMu,condCov] = conditionalMuCov(x,indices,globalMu,globalCov)

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


indices2 = indices;
indices1 = setdiff(1:length(globalMu),indices);

mu2 = globalMu(indices2);
mu1 = globalMu(indices1);

cov22 = globalCov(indices2,indices2);
cov12 = globalCov(indices1,indices2);
cov21 = globalCov(indices2,indices1);
cov11 = globalCov(indices1,indices1);

condMu = mu1 + (cov12*cov22^-1*(x - mu2)')';
condCov = cov11 - cov12*cov22^-1*cov21; 
