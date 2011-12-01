function varargout = prtUtilListDataGen
% prtUtilListDataGen - List all prtDataGen* files.
% 
% See also: prtDataGenBimodal, prtDataGenCircles, prtDataGenIris,
% prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
% prtDataGenProstate, prtDataGenSpiral, prtDataGenUnimodal, prtDataGenXor,


g = prtUtilSubDir(fullfile(prtRoot,'dataGen'),'*.m');

if nargout == 0
    fprintf('See also: ');
    for i = 1:length(g);
        [p,f] = fileparts(g{i});
        fprintf('%s, ',f);
    end;
    fprintf('\b\b');
    fprintf('\n');
else
    varargout = {g};
end