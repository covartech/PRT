function prtNewOutlierRemoval(defaultFileName)
% PRTNEWOUTLIERREMOVAL creates a new prtOutlierRemoval* M-file
%
%   PRTNEWOUTLIERREMOVAL creates a new prtOutlierRemoval* M-file including
%   definitions for all required methods and properties for
%   prtOutlierRemoval objects.  By convention, prtOutlierRemoval M-files
%   should start with the string prtOutlierRemoval, and file names must be
%   valid MATLAB function names (no special characters, spaces, etc.)
%
%   PRTNEWOUTLIERREMOVAL(FILENAME) enables the user to specify the name of the new
%   prtOutlierRemoval object from the command line.
%
%   %Example:
%   prtNewOutlierRemoval('prtOutlierRemovalTechnique');
%


preferredMfilePrefix = 'prtOutlierRemoval';
if nargin < 1
    defaultFileName = preferredMfilePrefix;
end
%Choose the right template file
templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewOutlierRemovalTemplate.mTemplate');

prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile);
