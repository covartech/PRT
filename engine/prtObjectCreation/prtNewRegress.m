function prtNewRegress(defaultFileName)
% PRTNEWREGRESS creates a new prtRegress* M-file
%
%   PRTNEWREGRESS creates a new prtRegress* M-file including definitions for
%   all required methods and properties for prtRegress objects.  By
%   convention, prtRegress M-files should start with the string prtRegress, and
%   file names must be valid MATLAB function names (no special characters,
%   spaces, etc.)
%
%   PRTNEWREGRESS(FILENAME) enables the user to specify the name of the new
%   prtRegress object from the command line.
%
%   %Example:
%   prtRegress('prtRegressAwesome');
%

preferredMfilePrefix = 'prtRegress';
if nargin < 1
    defaultFileName = preferredMfilePrefix;
end
%Choose the right template file
templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewRegressTemplate.mTemplate');

prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile);
