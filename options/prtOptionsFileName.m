function fileName = prtOptionsFileName()
% PRTOPTIONSFILENAME  Returns the file name and path of the prtOptions file
%   The returned fileName determines where the default PRT options are
%   saved. The location is 
%       %USERPATH%/prt/options/prtOptionsSave.mat
%   where USERPATH is the MATLAB start directory. See userpath()
%   When this directory does not exist it is automatically created.
%
%   fileName = prtOptionsFileName()
%
% See also: prtOptionsGet, prtOptionsSet, prtOptionsGetDefault,
%           prtOptionsSetDefault

saveDir = fullfile(strrep(userpath,';',''),'prt','options');
optionsFileName = 'prtOptionsSave.mat';

if ~isdir(saveDir)
    mkdir(saveDir);
end

fileName = fullfile(saveDir,optionsFileName);

