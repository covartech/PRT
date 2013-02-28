function [data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2,dimCheck)
%[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2)
%[data1,data2] = prtUtilDistanceParseInputs(dataSet1,dataSet2,dimCheck) 
% Boolean, whether to check data dimensionality
% Internal
% xxx Need Help xxx

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
    dimCheck = true;
end
if (isnumeric(dataSet1) && isnumeric(dataSet2)) || (islogical(dataSet1) && islogical(dataSet2))
    data1 = dataSet1;
    data2 = dataSet2;
elseif isa(dataSet1,'prtDataSetBase') && isa(dataSet2,'prtDataSetBase')
    data1 = dataSet1.getObservations;
    data2 = dataSet2.getObservations;
else
    error('prt:prtUtilDistanceParseInputs:invalidInputs','prtDistance functions require first two inputs to be numeric or prtDataSetBase, but inputs were: %s and %s',class(dataSet1),class(dataSet2));
end
if dimCheck
    if size(data1,2) ~= size(data2,2)
        error('prt:prtUtilDistanceParseInputs:invalidInputs','prtDistance functions require the dimensionality of the two inputs to match, but inputs are of dimension %d and %d',size(data1,2),size(data2,2));
    end
end
