clear classes
%% Discrete (uses old VB toolbox to generate)

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
