
% Build mex functions for your system
mex('-outdir',fullfile(prtRoot,'util','mex','prtUtilEvalCapTreeMex'),'-output','prtUtilEvalCapTreeMex',fullfile(prtRoot,'util','mex','prtUtilEvalCapTreeMex','prtUtilEvalCapTreeMex.c'))
