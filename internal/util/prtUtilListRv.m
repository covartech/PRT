function varargout = prtUtilListRv
% prtUtilListRv - List all prtRv* files.
% 
% See also: prtRv, prtRvDiscrete, prtRvGmm, prtRvIndependent, prtRvKde,
% prtRvMixture, prtRvMultinomial, prtRvMvn, prtRvUniform,
% prtRvUniformImproper, prtRvVq
%

g = prtUtilSubDir(fullfile(prtRoot,'rv'),'*.m','asdf');

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
