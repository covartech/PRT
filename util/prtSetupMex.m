function prtSetupMex(overRideCheck, overRideBuild)
% prtSetupMex Compile mex files for this system







if nargin < 1 || isempty(overRideCheck)
    overRideCheck = false;
end

if nargin < 2 || isempty(overRideBuild)
    overRideBuild = false;
end

assert(prtUtilIsLogicalScalar(overRideCheck),'overRideCheck must be a scalar logical');
assert(prtUtilIsLogicalScalar(overRideBuild) ,'overRideBuild must be a scalar logical');

if ~overRideCheck
    % Get selected c compiler information;
    hasMexSetup = false;
    try %#ok<TRYNC>
        cc = mex.getCompilerConfigurations('c','selected');
        hasMexSetup = ~isempty(cc);
        
        cc = mex.getCompilerConfigurations('cpp','selected');
        hasMexSetup = hasMexSetup && ~isempty(cc);
    end
    
    if ~hasMexSetup
        error('prt:prtSetupMex','prtSetupMex did not find that your MATLAB is setup to create mex files. If you have not previously setup mex compilation on this computer see the <a href="matlab:doc mex">MATLAB mex documentation</a>. If you think this is a mistake rerun prtSetupMex as >> prtSetupMex(true)')
    end
end


% Build mex functions for your system
if ~isempty(strfind(computer,'64'))
    extraInputs = {'-largeArrayDims'};
else
    extraInputs = {};
end

% prtUtilEvalCapTreeMex
mexFile = which('prtUtilEvalCapTreeMex');
if isempty(mexFile) || overRideBuild
    mex('-outdir',fullfile(prtRoot,'util','mex','prtUtilEvalCapTreeMex'),'-output','prtUtilEvalCapTreeMex',fullfile(prtRoot,'util','mex','prtUtilEvalCapTreeMex','prtUtilEvalCapTreeMex.c'));
end

% prtUtilSumExp
mexFile = which('prtUtilSumExp');
if isempty(mexFile) || overRideBuild
    mex('-outdir',fullfile(prtRoot,'util','mex','prtUtilSumExp'),'-output','prtUtilSumExp',fullfile(prtRoot,'util','mex','prtUtilSumExp','prtUtilSumExp.c'));
end

% LIBS SVM
mexFile1 = which('prtExternal.libsvm.libsvmread');
mexFile2 = which('prtExternal.libsvm.libsvmwrite');
if isempty(mexFile1) || isempty(mexFile2) || overRideBuild
    mex('-O','-c','-outdir',fullfile(prtRoot,'+prtExternal','+libsvm'),fullfile(prtRoot,'+prtExternal','+libsvm','svm.cpp'),extraInputs{:});
    mex('-O','-c','-outdir',fullfile(prtRoot,'+prtExternal','+libsvm'),fullfile(prtRoot,'+prtExternal','+libsvm','svm_model_matlab.c'),extraInputs{:});

    mex('-O','-outdir',fullfile(prtRoot,'+prtExternal','+libsvm'),fullfile(prtRoot,'+prtExternal','+libsvm','svmtrain.c'),fullfile(prtRoot,'+prtExternal','+libsvm','svm.o'),fullfile(prtRoot,'+prtExternal','+libsvm','svm_model_matlab.o'),extraInputs{:});
    mex('-O','-outdir',fullfile(prtRoot,'+prtExternal','+libsvm'),fullfile(prtRoot,'+prtExternal','+libsvm','svmpredict.c'),fullfile(prtRoot,'+prtExternal','+libsvm','svm.o'),fullfile(prtRoot,'+prtExternal','+libsvm','svm_model_matlab.o'),extraInputs{:});

    mex('-outdir',fullfile(prtRoot,'+prtExternal','+libsvm'),'-output','libsvmread',fullfile(prtRoot,'+prtExternal','+libsvm','libsvmread.c'),extraInputs{:});
    mex('-outdir',fullfile(prtRoot,'+prtExternal','+libsvm'),'-output','libsvmwrite',fullfile(prtRoot,'+prtExternal','+libsvm','libsvmwrite.c'),extraInputs{:});
end

% Combinator
mex(fullfile(prtRoot,'+prtExternal','+combinator','cumsumall.cpp'));

mexFile = which('prtRvUtilLogForwardsBackwards');
if isempty(mexFile) || overRideBuild
    mex('-outdir',fullfile(prtRoot,'util','mex','prtRvUtilLogForwardsBackwards'),'-output','prtRvUtilLogForwardsBackwards',fullfile(prtRoot,'util','mex','prtRvUtilLogForwardsBackwards','prtRvUtilLogForwardsBackwards.c'));
end





%fprintf('prt mex-file compilation complete\n');
