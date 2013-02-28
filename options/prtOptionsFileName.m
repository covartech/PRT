function fileName = prtOptionsFileName()
% PRTOPTIONSFILENAME  Returns the file name and path of the prtOptions file
%   The returned fileName determines where the default PRT options are
%   saved. The location is 
%       %prefdir%/prt/options/prtOptionsSave.mat
%   where %prefdir% is the directory returned by the MATLAB function
%   prefdir. When this directory does not exist it is automatically
%   created.
%
%   fileName = prtOptionsFileName()
%
% See also: prtOptionsGet, prtOptionsSet, prtOptionsGetDefault,
%           prtOptionsSetDefault

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


saveDir = fullfile(prefdir,'prt','options');
optionsFileName = 'prtOptionsSave.mat';

if ~isdir(saveDir)
    mkdir(saveDir);
end

fileName = fullfile(saveDir,optionsFileName);

