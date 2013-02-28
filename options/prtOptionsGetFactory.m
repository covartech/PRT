function defaultOptions = prtOptionsGetFactory()
% prtOptionsGetFactory  Get the factory options for the PRT
%   PRT factory options are hard coded in MATLAB class m files stored
%   within the prtOptions package. prtOptionsGetFactory returns a structure
%   with each of these classes loaded into a structure with field names
%   equal to the class names
%
%   defaultOptions = prtOptionsGetFactory()
%
% See also. prtOptionsGet, prtOptionsSet, prtOptionsSetDefault

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


optionsPackageInfo = meta.package.fromName('prtOptions');

if isempty(optionsPackageInfo)
    error('Package prtOptions was not found on path');
end

for iClass = 1:length(optionsPackageInfo.Classes)
    defaultOptions.(strrep(optionsPackageInfo.Classes{iClass}.Name,'prtOptions.','')) = feval(optionsPackageInfo.Classes{iClass}.Name);
end
