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


preferredMfilePrefix = 'prtPreProc';
if nargin < 1
    defaultFileName = preferredMfilePrefix;
end
%Choose the right template file
templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewPreProcTemplate.mTemplate');

prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile);
