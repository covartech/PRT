function prtSetup
% prtSetup - Guide user through setup process for the prt.
%   Including checking for a graphviz install and indexing the PRT
%   documentation so that it can be accessed through the help browser.
%
% Syntax: prtSetup()

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
% This is not ideal. To prevent this we have to copy the all of the files
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

rmdir(fullfile(prtRoot,'doc'),'s');

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
