function result = prtTestClass
% This function will check basic object construction and management

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
result = true;



%% Object contruction error checks
error = true;  % We will want all these things to error

classifier = prtClassMap;

try
    classifier.name = 'sam';
    error = false;  % Set it to false if the preceding operation succeeded
catch
    % do nothing
    % We can potentially catch and check the error string here
    % For now, just be happy it is erroring out.
end

try
    classifier.nameAbbreviation = 'sam';
    error = false;
catch
    % do nothing
end

try
    classifier.isMary = 1;
    error = false;
catch
    % do nothing
end

try
    classifier.yieldsMaryOutput = 1;
    error = false;
catch
    % do nothing
end

try
    classifier.twoClassParadigm = 'sam';
    error = false;
catch
    % do nothing
end

try
    classifier.DataSet = 2;
    error = false;
catch
    % do nothing
end

% %% XXX This should error out
% try
%     classifier.verboseStorage = 'sam'; 
%     error = false;  
% catch
%     % do nothing
% end

%%
% Object construction non-errors
% We want these to be settable

noerror = true;

try
    classifier.userData = 'sam';   
catch
    noerror = false;
end

try
    classifier.verboseStorage = 0;   
catch
    noerror = false;
end

try
    classifier.plotOptions = prtOptions.prtOptionsDataSetClassPlot;   
catch
    noerror = false;
end

result = result & error & noerror;
