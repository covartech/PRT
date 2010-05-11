function varargout = prtScoreRocBayesianBootstrapNfa(varargin)
% PRTSCOREROCBAYESIANBOOTSTRAPNFA - Bayesian Boot strap an ROC curve
%   Performs Bayesian boot strap sampling of an ROC curve and generates the
%   100*(1-alpha) percent percentile uniform credible band. This is done
%   following the methodology in:
%
%   Non-parametric estimation of ROC curve
%   J. Gu, S. Ghosal, and A. Roy
%   Statistics in Medicine, Vol. 27, 5407—5420, 2008.
%   http://www4.stat.ncsu.edu/~ghosal/papers/ROCBB.pdf
%
%   This function maps the outputs of probability of false alarm to the
%   number of false alarms at each threshold so that FAR can be calculated.
%
%   See also: prtScoreRocBayesianBootstrap()
%
% Syntax: prtScoreRocBayesianBootstrapNfa(ds, y)
%         prtScoreRocBayesianBootstrapNfa(ds, y, nBootStrapSamples)
%         prtScoreRocBayesianBootstrapNfa(ds, y, nBootStrapSamples, nPfSamples)
%         prtScoreRocBayesianBootstrapNfa(ds, y, nBootStrapSamples, nPfSamples, alpha)
%         [nFaSamples, pdMean, pdConfRegion, bootStrappedPds] = prtScoreRocBayesianBootstrapNfa(...)
%
%         Note: If no output arguments are requested the mean and credible 
%               interval are plotted using prtScoreRocConfidencePlot()
%
% Inputs:
%   ds - Decision statistics of detection algorithm
%   y - Binary label vector of truth
%   nBootStrapSamples - The number of boot strapped ROC curves used to
%       calculated the mean and credible interval. (Default: 500)
%   nPfSamples - The number of samples of Probability of False alarm at
%       with which to sample the ROC curve. (Default: 500)
%   alpha - The size of the credible interval 100*(1-alpha) 
%       (Default: 0.05 - Corresponding to a 95% credible band)
%
% Outputs:
%   nFaSamples - Number of false alarms probabilities at which the
%       bootstrapped ROC curves are evaluated
%   pdMean - Mean of the bootstrapped ROC curves
%   pdConfRegion - 100*(1-alpha) percent percentile uniform credible band
%       reported as two ROC curves [upperPdCurve, lowerPdCurve]
%   bootStrappedPds - All samples of the bootstrapped ROC curves
%
% Example
%   % This simulates a GLRT in a noise noise situation;
%   nSamplesEachHyp = 500;
%   x = cat(1,2*randn(nSamplesEachHyp,1),randn(nSamplesEachHyp,1));
%   y = cat(1,ones(nSamplesEachHyp,1),zeros(nSamplesEachHyp,1));
%   ds = x.^2;
%   prtScoreRocBayesianBootstrapNfa(ds, y)
%
%   % To make a FAR plot we have to request the outputs, divide by the area
%   % and make the plot ourselves
%   totalArea = 1000;
%   [nFaSamples, pdMean, pdConfRegion] = prtScoreRocBayesianBootstrapNfa(ds, y);
%   prtScoreRocConfidencePlot(nFaSamples./totalArea, pdMean, pdConfRegion)
%   
% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: kdm@ee.duke.edu
% Created: 09-May-2010

%% Call the non Nfa version

[pfSamples, pdMean, pdConfRegion, bootStrappedPds] = prtScoreRocBayesianBootstrap(varargin{:});

%%
% Clean up y (just in case)
y = varargin{2};
uY = unique(y(:));
newY = y;
newY(y==uY(1)) = 0;
newY(y==uY(2)) = 1;
y = newY;
y = y(:); % Make sure y is a column

nH0 = sum(y==0);

nFaSamples = pfSamples*nH0;


%% Package Outputs
if nargout == 0
    prtScoreRocConfidencePlot(nFaSamples,pdMean,pdConfRegion)
else
    varargout = {nFaSamples, pdMean, pdConfRegion, bootStrappedPds};
end