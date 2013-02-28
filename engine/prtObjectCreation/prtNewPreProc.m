function prtNewPreProc(defaultFileName)
% PRTNEWPREPROC creates a new prtClass* M-file
%
%   PRTNEWPREPROC creates a new prtPreProc* M-file including definitions for
%   all required methods and properties for prtPreProc objects.  By
%   convention, prtPreProc M-files should start with the string prtPreProc, and
%   file names must be valid MATLAB function names (no special characters,
%   spaces, etc.)
%
%   PRTNEWPREPROC(FILENAME) enables the user to specify the name of the new
%   prtPreProc object from the command line.
%
%   %Example:
%   prtPreProc('prtPreProcTechnique');
%

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



preferredMfilePrefix = 'prtPreProc';
if nargin < 1
    defaultFileName = preferredMfilePrefix;
end
%Choose the right template file
templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewPreProcTemplate.mTemplate');

prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile);
