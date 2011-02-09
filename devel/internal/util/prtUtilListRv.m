% 
% See also: prtRv, prtRvDiscrete, prtRvGmm, prtRvIndependent, prtRvKde,
% prtRvMixture, prtRvMultinomial, prtRvMvn, prtRvUniform,
% prtRvUniformImproper, prtRvVq
%

g = subDir(fullfile(prtRoot,'rv'),'*.m');
g = prtUtilRemoveStrCell(g,'util');

fprintf('See also: ');
for i = 1:length(g); 
    [p,f] = fileparts(g{i}); 
    fprintf('%s, ',f);
end; 
fprintf('\b\b');
fprintf('\n');
