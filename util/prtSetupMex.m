function prtSetupMex(overRideCheck, overRideBuild)
% prtSetupMex Compile mex files for this system

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
