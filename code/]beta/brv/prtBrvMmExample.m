clear classes

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
ds = prtDataGenOldFaithful; 


mix = prtBrvMixture('components',repmat(prtBrvMvn,10,1), 'vbVerboseText',true, 'vbVerbosePlot', true, 'vbConvergenceThreshold',1e-10);
[mixLearned, training] = mix.vbBatch(ds);
%%
clear classes
ds = prtDataGenOldFaithful; 

mix = prtBrvDpMixture('components',repmat(prtBrvMvn,10,1), 'vbVerboseText',true, 'vbVerbosePlot', true, 'vbConvergenceThreshold',1e-10);
[mixLearned, training] = mix.vbBatch(ds);

%%

%%
ds = prtDataGenOldFaithful; 

mix = prtBrvMixture('components',repmat(prtBrvMvn,10,1), 'vbVerboseText',true, 'vbVerbosePlot', true, 'vbConvergenceThreshold',1e-10,'vbVerboseMovie',1);
[mixLearned, training] = mix.vbBatch(ds);

dpmix = prtBrvDpMixture('components',repmat(prtBrvMvn,10,1), 'vbVerboseText',true, 'vbVerbosePlot', true, 'vbConvergenceThreshold',1e-10,'vbVerboseMovie',1);
[dpmixLearned, dpTraining] = mix.vbBatch(ds);
%%
movie2gif(mixLearned.vbVerboseMovieFrames,fullfile(myDesktop,'vbGmm'))
movie2gif(dpmixLearned.vbVerboseMovieFrames,fullfile(myDesktop,'vbDpGmm'))









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
