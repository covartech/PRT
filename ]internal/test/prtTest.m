function prtTest(functionNames)
% PRTTEST - Runs each function in the directory where this file lives.
%
% Syntax: prtTest
%
% Each of these functions must take zero input arguments and return a 
% logical saying whether the code executed properly.

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



if nargin < 1 || isempty(functionNames)
    testMFiles = dir(fullfile(fileparts(which(mfilename)),'*.m'));
    functionNames = setdiff({testMFiles.name},{'prtTest.m','prtTestClassifiers.m','prtTestSmoke.m','prtTestGenerateClassBaselines.m','prtTestGenerateRegressBaseline.m','prtTestRunCrossVal.m'});
    [garbage, functionNames] = cellfun(@(c)fileparts(c),functionNames,'uniformOutput',false);
end

maxStrLength = max(cellfun(@(c)length(c),functionNames));
functionNames = cellfun(@(c)cat(2,strtrim(c),repmat(' ',1,maxStrLength-length(strtrim(c)))),functionNames,'uniformoutput',false);

% Remove prtTestSmoke as it is redundant.
functionNames = prtUtilRemoveStrCell(functionNames,'prtTestSmoke');

fprintf('\n PRT Test Suit - %d Test Cases\n',length(functionNames));
overallFailure = false(length(functionNames),1);
executionFailure = overallFailure;
for iFun = 1:length(functionNames)
    cFunStr = functionNames{iFun};
    
    fprintf('\t%03d. %s ...',iFun,cFunStr);
    
    cStartTime = now;
    cCodeExecuteFailure = false;
    try
        cResult = feval(strtrim(functionNames{iFun}));
    catch cME
        cResult = false;
        cCodeExecuteFailure = true;
    end
    cEndTime = now;
    cElapsedTime = cEndTime-cStartTime;
    
    if cCodeExecuteFailure
        fprintf('\tFailure in code execution!!!!\n')
    else
        if cResult 
            fprintf('\tValidated in %s\n',datestr(cElapsedTime,'HH:MM:SS'))
        else
            fprintf('\tFailure in validation!!!!\n')
        end
    end
    
    overallFailure(iFun) = ~cResult;
    executionFailure(iFun) = cCodeExecuteFailure;
end
fprintf(' All Tests Evaluated.')

if all(~overallFailure)
    fprintf(' All Tests Validated.\n')
else
    fprintf('\n\n');
    fprintf(' Some Tests have Failed Validation! %d overall failures\n',sum(overallFailure))
    for iFun = 1:length(functionNames)
        if overallFailure(iFun)
            if executionFailure(iFun)
                fprintf('\t%s - Execution Failure\n',functionNames{iFun})
            else
                fprintf('\t%s - Validation Failure\n',functionNames{iFun})
            end
        end
    end
end

fprintf('\n');
