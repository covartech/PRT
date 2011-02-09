% 
% See also: prtDataGenBimodal, prtDataGenCircles, prtDataGenIris,
% prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
% prtDataGenProstate, prtDataGenSpiral, prtDataGenUnimodal, prtDataGenXor,
% 

g = subDir(fullfile(prtRoot,'dataGen'),'*.m');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
