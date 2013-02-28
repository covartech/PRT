function Results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds)
%Results = prtUtilEvalParseAndRun(classifier,dataSet,nFolds)
%  Called internally by prtEval* as a way to parse inputs and generate
%  results

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


assert(nargin >= 2,'prt:prtEval:BadInputs','prtEval* functions require at least two input arguments');
assert(isa(classifier,'prtAction') && isa(dataSet,'prtDataSetBase'),'prt:prtEvalAuc:BadInputs','prtEvalAuc inputs must be sublcasses of prtClass and prtDataSetBase, but input one was a %s, and input 2 was a %s',class(classifier),class(dataSet));

if isscalar(nFolds)
    Results = classifier.kfolds(dataSet,nFolds);
else
    Results = classifier.crossValidate(dataSet,nFolds);
end
