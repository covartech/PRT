function varargout = prtScoreRocBayesianBootstrapNfa(varargin)
% prtScoreRocBayesianBootstrapNfa   Generate a reciever operator characteristic curve with Bayesian Boostrapping
%
%   prtScoreRocBayesianBootstrapNfa(DECSTATS,LABELS) plots the receiver
%   operator characteristic curve for the decision statistics DECSTATS and
%   the corresponding labels LABELS. DECSTATS must be a Nx1 vector of
%   decision statistics. LABELS must be a Nx1 vector of binary class
%   labels. This behavior is the same as prtScoreRocBayesianBootstrap. The
%   only difference is when output arguments are requested (see below).
%
%   prtScoreRocBayesianBootstrapNfa performs Bayesian boot strap sampling
%   of an ROC curve and generates the 100*(1-alpha) percent percentile
%   uniform credible band. The default alpha is .05, corresponding to a 95%
%   credible band. This is done following the methodology in:
%
%   Non-parametric estimation of ROC curve J. Gu, S. Ghosal, and A. Roy
%   Statistics in Medicine, Vol. 27, 5407—5420, 2008.
%   http://www4.stat.ncsu.edu/~ghosal/papers/ROCBB.pdf
%
%   prtScoreRocBayesianBootstrapNfa(DECSTATS,LABELS,
%   NBOOTSAMP) Specifies the nummber of boostrap samples NBOOTSAMP. The
%   default value is 1000.
%
%   prtScoreRocBayesianBootstrapNfa(DECSTATS,LABELS, [],
%   NPFSAMP) Specfies the number of samples of probability of false alarm
%   at with which to sample the ROC curve. The default is 500.
%
%   prtScoreRocBayesianBootstrapNfa(DECSTATS,LABELS, [],
%   [], ALPHA) Specifies ALPHA, the size of the credible interval
%   100*(1-alpha). The default is 0.05, corresponding to a 95% credible
%   band
%
%   [NFA, PDMEAN,PDCONFREGION, BOOTSTRAPPEDPDS] =
%   prtScoreRocBayesianBootstrapNfa(...) outputs NFA, the
%   number of false alarms at which the bootstrapped ROC curves are
%   evaluated. PDMEAN, the mean of the bootstrapped ROC curves,
%   PDCONFREGION, the 100*(1-alpha) percent percentile uniform credible
%   band reported as the upper and lower Pd curves. BOOTSTRAPPEDPDS, all
%   samples of the bootstrapped ROC curves
%
%    Example:     
%    TestDataSet = prtDataGenBimodal;       % Create some test and
%    TrainingDataSet = prtDataGenBimodal;   % training data
%    classifier = prtClassSvm;             % Create a classifier
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    % Find the number of false alarms at the corresponding PD.
%    [nf, pd]= prtScoreRocBayesianBootstrapNfa(classified.getX, TestDataSet.getY, [],[],.2);
%
%   See also prtScoreConfusionMatrix, prtScoreRmse, prtScoreRoc,
%   prtScoreRoc, prtScorePercentCorrect

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





%% Call the non Nfa version

[pfSamples, pdMean, pdConfRegion, bootStrappedPds] = prtScoreRocBayesianBootstrap(varargin{:});


%% Clean up y (just in case)
y = varargin{2};
uY = unique(y(:));
newY = y;
newY(y==uY(1)) = 0;
newY(y==uY(2)) = 1;
y = newY;
y = y(:); % Make sure y is a column


%% Transform pfSamples to nFA
nH0 = sum(y==0);

nFaSamples = pfSamples*nH0; 


%% Package Outputs
if nargout == 0
    prtUtilPlotRocConfidence(nFaSamples,pdMean,pdConfRegion)
else
    varargout = {nFaSamples, pdMean, pdConfRegion, bootStrappedPds};
end
