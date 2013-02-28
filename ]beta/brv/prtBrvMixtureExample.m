%% Dirichlet Mixture

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
clear classes

ds = prtDataGenOldFaithful; 

mix = prtBrvMixture('components', repmat(prtBrvMvn,5,1), 'vbVerboseText', true, 'vbVerbosePlot', true, 'vbConvergenceThreshold', 1e-11);

[mixLearned, training] = mix.vbBatch(ds);

%% DP Mixture
clear classes
ds = prtDataGenOldFaithful;

mix = prtBrvDpMixture('components',repmat(prtBrvMvn,15,1), 'vbVerboseText',true, 'vbVerbosePlot', true, 'vbConvergenceThreshold',1e-10);
[mixLearned, training] = mix.vbBatch(ds);

%% Online Dirichlet Mixture

clear classes
%ds = prtDataGenOldFaithful;
ds = prtDataGenBimodal(5000);

mix = prtBrvMixture('components',repmat(prtBrvMvn,25,1),'vbOnlineLearningRateFunctionHandle',@(t)(32 + t).^(-0.6),'vbVerbosePlot',true,'vbOnlineBatchSize',25,'vbOnlineFullDataSetSize',ds.nObservations);
mixLearned = mix.vbOnline(ds.X);


%% Online DP Mixture

clear classes
ds = prtDataGenOldFaithful;
%ds = prtDataGenBimodal(5000);

mix = prtBrvDpMixture('components',repmat(prtBrvMvn,50,1),'vbOnlineLearningRateFunctionHandle',@(t)(32 + t).^(-0.8),'vbVerbosePlot',true,'vbOnlineBatchSize',25,'vbOnlineFullDataSetSize',ds.nObservations);
mixLearned = mix.vbOnline(ds.X);

%%





%% MCMC Dirichlet
clear classes
%ds = prtDataGenOldFaithful; 
ds = prtDataGenBimodal;

mix = prtBrvMixture('components', repmat(prtBrvMvn,5,1), 'mcmcVerboseText', false, 'mcmcVerbosePlot', 100, 'mcmcTotalIterations', 5000);

[mixLearned, training] = mix.mcmc(ds);
