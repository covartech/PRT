function prtNewKernel(defaultFileName)
% PRTNEWKERNEL creates a new prtClass* M-file
%
%   PRTNEWKERNEL creates a new prtKernel* M-file including definitions for
%   all required methods and properties for prtKernel objects.  By
%   convention, prtKernel M-files should start with the string prtKernel, and
%   file names must be valid MATLAB function names (no special characters,
%   spaces, etc.)
%
%   PRTNEWKERNEL(FILENAME) enables the user to specify the name of the new
%   prtKernel object from the command line.
%
%   %Example:
%   prtNewKernel('prtKernelNew');
%


preferredMfilePrefix = 'prtKernel';
if nargin < 1
    defaultFileName = preferredMfilePrefix;
end
%Choose the right template file
templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewKernelTemplate.mTemplate');

prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile);
