function prtSetup
% prtSetup - Guide user through setup process for the prt.
%   Including checking for a graphviz install and indexing the PRT
%   documentation so that it can be accessed through the help browser.
%
% Syntax: prtSetup()

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


try
    if datenum(version('-date')) < datenum('December 31, 2007')
        warning('prt:prtSetup','It appears that you may be using a version of MATLAB that is too old for the PRT. The PRT requires a version newer than 7.6 (2008a). The PRT may not function properly on your system.');
    end
end


% Check for graphviz
[err,output] = system('dot -V'); %#ok<NASGU>

if err
    warning('prt:prtSetup','Could not find GraphViz installation. Graphviz must be installed and on the system path to enable prtAlgorithm plotting. Go to http://www.graphviz.org/ and follow the installation instructions for your operating system.')
end

% Build help We could simply run this
%
% >> builddocsearchdb(fullfile(prtRoot,'doc'));
%
% However, this indexes all of the methods and properties of each class.
% This is not ideal. To prevent this we have to copy all of the files
% somewhere else. Delete the ones we don't want indexed, index, and then
% copy the files back. This is all because there is no way to prevent
% builddocsearchdb from searching particular files.

tempDocDir = fullfile(tempdir,'prt');
if ~isdir(tempDocDir)
    mkdir(tempDocDir)
end

copyfile(fullfile(prtRoot,'doc'),tempDocDir)

htmlFiles{1} = dir(fullfile(tempDocDir));
htmlFiles{1} = htmlFiles{1}(~cat(1,htmlFiles{1}.isdir));
htmlFiles{2} = dir(fullfile(tempDocDir,'functionReference','*.html'));

try
    rmdir(fullfile(prtRoot,'doc'),'s');
catch ME
    % do nothing
end
mkdir(fullfile(prtRoot,'doc'));
mkdir(fullfile(prtRoot,'doc','functionReference'));
for iFile = 1:length(htmlFiles{1})
    copyfile(fullfile(tempDocDir,htmlFiles{1}(iFile).name),fullfile(prtRoot,'doc',htmlFiles{1}(iFile).name))
end

for iFile = 1:length(htmlFiles{2})
    copyfile(fullfile(tempDocDir,'functionReference',htmlFiles{2}(iFile).name),fullfile(prtRoot,'doc','functionReference',htmlFiles{2}(iFile).name))
end

builddocsearchdb(fullfile(prtRoot,'doc'));

copyfile(tempDocDir,fullfile(prtRoot,'doc'));
rmdir(tempDocDir,'s');
