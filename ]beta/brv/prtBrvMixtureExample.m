%% Dirichlet Mixture





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
