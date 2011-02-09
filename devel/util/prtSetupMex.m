function prtSetupMex(overRideCheck)
% prtSetupMex Compile mex files for this system

if nargin < 1
    overRideCheck = false;
end

assert(prtUtilIsLogicalScalar(overRideCheck),'overRideCheck must be a scalar logical');

if ~overRideCheck
    % Get selected c compiler information;
    hasMexSetup = false;
    try %#ok<TRYNC>
        cc = mex.getCompilerConfigurations('c','selected');
        hasMexSetup = ~isempty(cc);
    end
    
    if ~hasMexSetup
        error('prt:prtSetupMex','prtSetupMex did not find that your MATLAB is setup to create mex files. If you think this is a mistake rerun prtSetupMex as >> prtSetupMex(true)')
    end
end


% Build mex functions for your system
mex('-outdir',fullfile(prtRoot,'util','mex','prtUtilEvalCapTreeMex'),'-output','prtUtilEvalCapTreeMex',fullfile(prtRoot,'util','mex','prtUtilEvalCapTreeMex','prtUtilEvalCapTreeMex.c'))


% libSvm
% 
% % add -largeArrayDims on 64-bit machines
% 
% mex -O -c svm.cpp
% mex -O -c svm_model_matlab.c
% mex -O svmtrain.c svm.obj svm_model_matlab.obj
% mex -O svmpredict.c svm.obj svm_model_matlab.obj
% mex -O libsvmread.c
% mex -O libsvmwrite.c
% 
% %%
% % mex -O -c svm.cpp -largeArrayDims
% % mex -O -c svm_model_matlab.c -largeArrayDims
% % mex -O svmtrain.c svm.obj svm_model_matlab.obj -largeArrayDims
% % mex -O svmpredict.c svm.obj svm_model_matlab.obj -largeArrayDims
% % mex -O libsvmread.c -largeArrayDims
% % mex -O libsvmwrite.c -largeArrayDims
% 
