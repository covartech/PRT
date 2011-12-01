function prtNewCluster(defaultFileName)
% PRTNEWCLUSTER creates a new prtCluster* M-file
%
%   PRTNEWCLUSTER creates a new prtCluster* M-file including definitions for
%   all required methods and properties for prtCluster objects.  By
%   convention, prtCluster M-files should start with the string prtCluster, and
%   file names must be valid MATLAB function names (no special characters,
%   spaces, etc.)
%
%   PRTNEWCLUSTER(FILENAME) enables the user to specify the name of the new
%   prtCluster object from the command line.
%
%   %Example:
%   prtNewCluster('prtClusterAwesome');
%

preferredMfilePrefix = 'prtCluster';
if nargin < 1
    defaultFileName = preferredMfilePrefix;
end
%Choose the right template file
templateFile = fullfile(prtRoot,'engine','prtObjectCreation','templates','prtNewClusterTemplate.mTemplate');

prtUtilNewFileFromTemplate(defaultFileName,preferredMfilePrefix,templateFile);
