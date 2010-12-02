function options = prtOptionsSetDefault

saveDir = fullfile(strrep(userpath,';',''),'prt','options');
optionsFileName = 'prtOptionsSave.mat';

options = prtOptionsGetDefault();
        
save(fullfile(saveDir,optionsFileName),'options');

% We must clear the function prtOptionsGet to purge persistent variables
% which are now out of date.
clear prtOptionsGet