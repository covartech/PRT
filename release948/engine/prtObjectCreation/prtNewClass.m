function prtNewClass(defaultFileName)
% PRTNEWCLASS creates a new prtClass* M-file
%
%   PRTNEWCLASS creates a new prtClass* M-file including definitions for
%   all required methods and properties for prtClass objects.  By
%   convention, prtClass M-files should start with the string prtClass, and
%   file names must be valid MATLAB function names (no special characters,
%   spaces, etc.)
%
%   PRTNEWCLASS(FILENAME) enables the user to specify the name of the new
%   prtClass object from the command line.
%
%   %Example:
%   prtNewClass('prtClassAwesome');
%


preferredMfilePrefix = 'prtClass';
if nargin < 1
    defaultFileName = preferredMfilePrefix;
end
%Choose the right template file
templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewClassTemplate.mTemplate');

prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile);
