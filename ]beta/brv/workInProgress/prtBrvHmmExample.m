clear classes
%% Discrete (uses old VB toolbox to generate)
TrueQ.Options = vbhmmOptions(discreteOptions);
TrueQ.PosteriorMean.init = [1 0 0];
TrueQ.PosteriorMean.transition = toeplitz([0.9 0.05 0.05]);
TrueQ.PosteriorMean.Sources(1,1).probs = [0.1 0.8 0.1];
TrueQ.PosteriorMean.Sources(2,1).probs = [0.8 0.1 0.1];
TrueQ.PosteriorMean.Sources(3,1).probs = [0.1 0.1 0.8];

[Obs, States] = vbhmmRnd(TrueQ,[1000 1000 1000]);

h = prtBrvHmm(repmat(prtBrvDiscrete(3),3,1));
h.vbVerbosePlot = true;
h.vbVerboseText = true;
h.vbConvergenceThreshold = 1e-10;

[hOut, training] = h.vb(Obs);
%%

TrueQ.Options = vbhmmOptions(discreteOptions);
TrueQ.PosteriorMean.init = [1 0 0];
TrueQ.PosteriorMean.transition = toeplitz([0.9 0.05 0.05]);
TrueQ.PosteriorMean.Sources(1,1).probs = [0.1 0.8 0.1];
TrueQ.PosteriorMean.Sources(2,1).probs = [0.8 0.1 0.1];
TrueQ.PosteriorMean.Sources(3,1).probs = [0.1 0.1 0.8];

[Obs, States] = vbhmmRnd(TrueQ,[1000 1000 1000]);

h = prtBrvDpHmm(repmat(prtBrvDiscrete(3),10,1));
h.vbVerbosePlot = true;
h.vbVerboseText = true;
h.vbConvergenceThreshold = 1e-10;

[hOut, training] = h.vb(Obs);