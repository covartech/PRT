clear classes
%ds = prtDataGenOldFaithful; 
ds = prtDataGenBimodal;

mix = prtBrvMixture('components', repmat(prtBrvMvn,5,1), 'vbVerboseText', true, 'vbVerbosePlot', true, 'vbConvergenceThreshold', 1e-11);

mix.vbIterationPlotNumSamplesThreshold = 200;
mix.vbIterationPlotNumBootstrapSamples = 100;

%[mixLearned, training] = mix.vbBatch(rt(prtPreProcZmuv,ds));
[mixLearned, training] = mix.vbBatch(ds);

%[mixLearned, training] = mix.vbBatch(ds.retainFeatures(2));

%%

clear classes
%ds = prtDataGenOldFaithful; 
ds = prtDataGenMultipleInstance;

mix = prtBrvMixture('components', repmat(prtBrvMvn,20,1), 'vbVerboseText', true, 'vbVerbosePlot', true, 'vbConvergenceThreshold', 1e-15);
[mixLearned, training] = mix.vbBatch(ds.expandedData);

%%
clear classes
%ds = prtDataGenOldFaithful;
ds = prtDataGenBimodal;

mix = prtBrvDpMixture('components',repmat(prtBrvMvn,15,1), 'vbVerboseText',true, 'vbVerbosePlot', true, 'vbConvergenceThreshold',1e-10);
[mixLearned, training] = mix.vbBatch(ds);

%%

clear classes
%ds = prtDataGenOldFaithful; 
ds = prtDataGenTopicModel;

mix = prtBrvDpMixture('components',repmat(prtBrvDiscrete,50,1), 'vbVerboseText',true, 'vbVerbosePlot', true, 'vbConvergenceThreshold',1e-15);
[mixLearned, training] = mix.vbBatch(ds);

%%

O = vbdpmmOptions(mvnOptions);
O.verbosePlot = true;
O.verboseText = true;
P = vbdpmmPrior(10,mvnPrior(2));

Q = vbdpmm(x,P,O);  
%%

clear classes
x = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[3 3],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);

mm = prtBrvMm(repmat(prtBrvMvn(2),2,1));
mm.vbVerboseText = false;
mm.vbVerbosePlot = false;
[mmLearned, training] = mm.vb(x);
%%

%x2 = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[-2 -2],'sigma',eye(2)),prtRvMvn('mu',[5 5],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);
x2 = draw(prtRvMvn('mu',[-2 -2],'sigma',eye(2)),100);
mmLearned.vbOnlineKappa = 0.1;
mmLearned.vbOnlineTau = 10;
mmLearned.vbVerbosePlot = true;
[mmLearnedAgain, training] = mmLearned.vbOnlineUpdate(mm,x2);

%%


clear classes
%x = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[3 3],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);
x = cat(1,draw(prtRvMvn('mu',[-2 -2],'sigma',eye(2)),100),draw(prtRvMvn('mu',[2 2],'sigma',eye(2)),100));

clusterDensity = prtBrvMvn(2);
clusterDensity.initModifiyPrior = false;

mm = prtBrvMm(repmat(clusterDensity,1,1));
mm.vbVerboseText = false;
mm.vbVerbosePlot = true;
mm.vbOnlineBatchSize = 1;
mm.vbOnlineKappa  = 0.01;
mm.vbOnlineTau  = 10;

initSamples = 10;

[mmLearnedOnline, mmLearnedOnlinePrior, training] = mm.vbInitialize(x(1:initSamples,:));
mmLearnedOnline = mmLearnedOnline.vbM(mmLearnedOnlinePrior, x(1:initSamples,:), training);

mmLearnedOnline.vbOnlineUseStaticLambda = true;
mmLearnedOnline.vbOnlineStaticLambda = 0.1;
mmLearnedOnline.vbOnlineD = 25;

for iX = (initSamples+1):size(x,1)
    mmLearnedOnline = mmLearnedOnline.vbOnlineUpdate(mm,x(iX,:));
end