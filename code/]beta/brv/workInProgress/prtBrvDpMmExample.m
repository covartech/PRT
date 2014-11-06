close all

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

ds = prtDataGenOldFaithful; x = ds.getX;
%x = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[3 3],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);

mm = prtBrvDpMm(repmat(prtBrvMvn(2),25,1));
mm.mixingProportions.model.useGammaPriorOnScale = false;
mm.mixingProportions.model.useOptimalSorting = true;
mm.mixingProportions.model.alphaGammaParams = [0.1 1];
mm.vbConvergenceThreshold = 1e-6;
mm.vbVerboseText = true;
mm.vbVerbosePlot = true;
mm.vbVerboseMovie = true;
[mmLearned, training] = mm.vb(x);

%%
clear classes
close all
%x = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[3 3],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);
x = cat(1,draw(prtRvMvn('mu',[-5 -5],'sigma',eye(2)),100),draw(prtRvMvn('mu',[5 5],'sigma',eye(2)),100));

clusterDensity = prtBrvMvn(2);
clusterDensity.initModifiyPrior = false;

mm = prtBrvDpMm(repmat(clusterDensity,10,1));
mm.mixingProportions.model.useGammaPriorOnScale = true;
mm.mixingProportions.model.useOptimalSorting = false;
mm.mixingProportions.model.alphaGammaParams = [1 1];
mm.vbVerboseText = true; % Doesn't currently do anything
mm.vbVerbosePlot = true;
mm.vbOnlineInitialBatchSize = mm.nComponents;
mm.vbOnlineBatchSize = 100;
mm.vbOnlineKappa = 0.55;
mm.vbOnlineTau = 64;
mm.vbMaxIterations = 200;

[mmLearnedOnline, training] = mm.vbOnline(x);
%%


clear classes
close all
%x = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[3 3],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);
x = cat(1,draw(prtRvMvb('probabilities',[0.9 0.1 0.9 0.1 0.9]),100),draw(prtRvMvb('probabilities',[0.1 0.9 0.1 0.9 0.1]),100));

clusterDensity = prtBrvMvb(5);

mm = prtBrvDpMm(repmat(clusterDensity,25,1));
mm.mixingProportions.model.useGammaPriorOnScale = false;
mm.mixingProportions.model.alphaGammaParams = [1 1];

mm.vbConvergenceThreshold = 1e-6;
mm.vbVerboseText = true;
mm.vbVerbosePlot = true;

[mmLearned, training] = mm.vb(x);

%%

clear classes
close all
%x = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[3 3],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);
%x = cat(1,draw(prtRvMvb('probabilities',[0.9 0.1 0.9 0.1 0.9]),100),draw(prtRvMvb('probabilities',[0.1 0.9 0.1 0.9 0.1]),100));

x = cat(1,draw(prtRvMvb('probabilities',[0.9 0.1 0.9 0.1 0.9]),100),draw(prtRvMvb('probabilities',[0.1 0.9 0.1 0.9 0.1]),100),draw(prtRvMvb('probabilities',[0.1 0.1 0.9 0.9 0.9]),100),draw(prtRvMvb('probabilities',[0.9 0.9 0.1 0.1 0.1]),100));

clusterDensity = prtBrvMvb(5);

mm = prtBrvDpMm(repmat(clusterDensity,25,1));
mm.mixingProportions.model.useGammaPriorOnScale = true;
mm.mixingProportions.model.useOptimalSorting = false;
mm.mixingProportions.model.alphaGammaParams = [1e-6 1e-6];

mm.vbVerboseText = true; % Doesn't currently do anything
mm.vbVerbosePlot = true;
mm.vbOnlineInitialBatchSize = mm.nComponents;
mm.vbOnlineBatchSize = 25;
mm.vbOnlineKappa = 0.55;
mm.vbOnlineTau = 64;
mm.vbMaxIterations = 100;
mm.vbVerboseMovie = true;

[mmLearnedOnline, training] = mm.vbOnline(x);

%%
movie2gif(mmLearnedOnline.vbVerboseMovieFrames,fullfile(myDesktop,'dpBinaryMixtureOnline'))
figure
imagesc(x), colormap(gray), ylabel('Observation'),set(gca,'xticklabel',[]), quickPng('binaryData')
%%
clear classes
x = cat(1,draw(prtRvMvb('probabilities',[0.9 0.1 0.9 0.1 0.9]),100),draw(prtRvMvb('probabilities',[0.1 0.9 0.1 0.9 0.1]),100),draw(prtRvMvb('probabilities',[0.1 0.1 0.9 0.9 0.9]),100),draw(prtRvMvb('probabilities',[0.9 0.9 0.1 0.1 0.1]),100));
y = prtUtilY(200,200);

ds = prtDataSetClass(x,y);

c = ezPrtMapMvbClassifier(size(x,2), 10);

cTrained = c.train(ds);

out = cTrained.run(ds);

%%


clear classes
close all

x = cat(1,draw(prtRvMvn('mu',[-5 -5],'sigma',eye(2)),100),draw(prtRvMvn('mu',[5 5],'sigma',eye(2)),100),...
          draw(prtRvMvn('mu',[5 -5],'sigma',eye(2)),100),draw(prtRvMvn('mu',[-5 5],'sigma',eye(2)),100));

y = prtUtilY(200,200);

ds = prtDataSetClass(x,y);

c = ezPrtMapMvnClassifier(size(x,2), 10);

cTrained = c.train(ds);

out = cTrained.run(ds);
%%

clear classes
close all
%x = draw(prtRvGmm('components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[3 3],'sigma',eye(2))),'mixingProportions',[0.6 0.4]),200);
%x = cat(1,draw(prtRvMvn('mu',[-5 -5],'sigma',eye(2)),100),draw(prtRvMvn('mu',[5 5],'sigma',eye(2)),100));
x = cat(1,draw(prtRvMvn('mu',[-2 -2],'sigma',eye(2)),100),draw(prtRvMvn('mu',[2 2],'sigma',eye(2)),100),...
          draw(prtRvMvn('mu',[2 -2],'sigma',eye(2)),100),draw(prtRvMvn('mu',[-2 2],'sigma',eye(2)),100));

clusterDensity = prtBrvMvn(2);
clusterDensity.initModifiyPrior = false;

mm = prtBrvDpMm(repmat(clusterDensity,10,1));
mm.mixingProportions.model.useGammaPriorOnScale = true;
mm.mixingProportions.model.useOptimalSorting = false;
mm.mixingProportions.model.alphaGammaParams = [1 1];
mm.vbVerboseText = true; % Doesn't currently do anything
mm.vbVerbosePlot = true;
mm.vbOnlineInitialBatchSize = mm.nComponents;
mm.vbOnlineBatchSize = 25;
mm.vbOnlineKappa = 0.55;
mm.vbOnlineTau = 64;
mm.vbMaxIterations = 200;
mm.vbVerboseMovie = true;

[mmLearnedOnline, training] = mm.vbOnline(x);
%%

movie2gif(mmLearnedOnline.vbVerboseMovieFrames(1:100),fullfile(myDesktop,'dpMvnMixtureOnline'))
figure
plot(prtDataSetClass(x)), ylabel('Dimension 2'), xlabel('Dimension 1'); quickPng('binaryData')


%%


close all
clear classes
[x, y] = draw(prtRvGmm('components',cat(1,...
    prtRvMvn('mu',[3 -3],'sigma',[1 -0.2; -0.2 1]),...
    prtRvMvn('mu',[3 3],'sigma',[1 0.2; 0.2 1]),...
    prtRvMvn('mu',[0 0],'sigma',[1 0; 0 1]),...
    prtRvMvn('mu',[-3 -3],'sigma',[1 0.2; 0.2 1]),...
    prtRvMvn('mu',[-3 3],'sigma',[1 -0.2; -0.2 1])),...
    'mixingProportions',[0.2 0.2 0.3 0.15 0.15]),500);

mm = prtBrvDpMm(repmat(prtBrvMvn(2),25,1));
mm.mixingProportions.model.useGammaPriorOnScale = false;
mm.mixingProportions.model.useOptimalSorting = true;
mm.mixingProportions.model.alphaGammaParams = [1 1];
mm.vbConvergenceThreshold = 1e-6;
mm.vbVerboseText = true;
mm.vbVerbosePlot = true;
mm.vbVerboseMovie = true;
[mmLearned, training] = mm.vb(x);
%%
movie2gif(mmLearned.vbVerboseMovieFrames,'exampleDpMixture')
%%
