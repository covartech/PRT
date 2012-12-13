function s = prtUtilTestRasmusbergpalmPath
%s = prtUtilTestRasmusbergpalmPath

s = which('nnsetup');
if isempty(s)
    error('Attempt to use a prt-object that relies on the external DeepLearning toolbox by Rasmusbergpalm.  That toolbox is not distributed with the PRT.  Please download the toolbox from https://github.com/rasmusbergpalm/DeepLearnToolbox, and follow the installation instructions');
end