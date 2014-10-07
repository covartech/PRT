function varargout = prtScoreRocBayesianBootstrap(ds, y, nBootStrapSamples, nPfSamples, alpha)
% prtScoreRocBayesianBootstrap   Generate a reciever operator characteristic curve with Bayesian Boostrapping
%
%   prtScoreRocBayesianBootstrap(DECSTATS,LABELS) plots the receiver operator
%   characteristic curve for the decision statistics DECSTATS and the
%   corresponding labels LABELS. DECSTATS must be a Nx1 vector of decision
%   statistics. LABELS must be a Nx1 vector of binary class labels.
%
%   prtScoreRocBayesianBootstrap performs Bayesian boot strap sampling of
%   an ROC curve and generates the 100*(1-alpha) percent percentile uniform
%   credible band. The default alpha is .05, corresponding to a 95%
%   credible band. This is done following the methodology in:
%
%   Non-parametric estimation of ROC curve
%   J. Gu, S. Ghosal, and A. Roy
%   Statistics in Medicine, Vol. 27, 5407—5420, 2008.
%   http://www4.stat.ncsu.edu/~ghosal/papers/ROCBB.pdf
%
%   prtScoreRocBayesianBootstrap(DECSTATS,LABELS, NBOOTSAMP) Specifies the
%   nummber of boostrap samples NBOOTSAMP. The default value is 1000.
%
%   prtScoreRocBayesianBootstrap(DECSTATS,LABELS, [], NPFSAMP) Specfies the
%   number of samples of probability of false alarm at with which to sample
%   the ROC curve. The default is 500.
%
%   prtScoreRocBayesianBootstrap(DECSTATS,LABELS, [], [], ALPHA) Specifies
%   ALPHA, the size of the credible interval 100*(1-alpha). The default is
%   0.05, corresponding to a 95% credible band
%
%   [PFSAMPLES, PDMEAN,PDCONFREGION, BOOTSTRAPPEDPDS] =
%   prtScoreRocBayesianBootstrap(...) outputs PFSAMPLES, the False alarm
%   probabilities at which the bootstrapped ROC curves are evaluated.
%   PDMEAN, the mean of the bootstrapped ROC curves, PDCONFREGION, the
%   100*(1-alpha) percent percentile uniform credible band reported as the
%   upper and lower Pd curves. BOOTSTRAPPEDPDS, all samples of the
%   bootstrapped ROC curves
%
%    Example:     
%    TestDataSet = prtDataGenSpiral;       % Create some test and
%    TrainingDataSet = prtDataGenSpiral;   % training data
%    classifier = prtClassSvm;             % Create a classifier
%    classifier = classifier.train(TrainingDataSet);    % Train
%    classified = run(classifier, TestDataSet);     
%    %  Plot the ROC
%    prtScoreRocBayesianBootstrap(classified.getX, TestDataSet.getY,[],[],.2);
%
%   See also prtScoreConfusionMatrix, prtScoreRmse, prtScoreRoc,
%   prtScoreRocNfa, prtScorePercentCorrect

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




% prtScoreRocBayesianBootstrap - Bayesian Boot strap an ROC curve
%   Performs Bayesian boot strap sampling of an ROC curve and generates the
%   100*(1-alpha) percent percentile uniform credible band. This is done
%   following the methodology in:
%
%   Non-parametric estimation of ROC curve
%   J. Gu, S. Ghosal, and A. Roy
%   Statistics in Medicine, Vol. 27, 5407—5420, 2008.
%   http://www4.stat.ncsu.edu/~ghosal/papers/ROCBB.pdf
%
% Syntax: prtScoreRocBayesianBootstrap(ds, y)
%         prtScoreRocBayesianBootstrap(ds, y, nBootStrapSamples)
%         prtScoreRocBayesianBootstrap(ds, y, nBootStrapSamples, nPfSamples)
%         prtScoreRocBayesianBootstrap(ds, y, nBootStrapSamples, nPfSamples, alpha)
%         [pfSamples, pdMean, pdConfRegion, bootStrappedPds] = prtScoreRocBayesianBootstrap(...)
%
%         Note: If no output arguments are requested the mean and credible 
%               interval are plotted using prtUtilPlotRocConfidence()
%
% Inputs:
%   ds - Decision statistics of detection algorithm
%   y - Binary label vector of truth
%   nBootStrapSamples - The number of boot strapped ROC curves used to
%       calculated the mean and credible interval. (Default: 1000)
%   nPfSamples - The number of samples of Probability of False alarm at
%       with which to sample the ROC curve. (Default: 500)
%   alpha - The size of the credible interval 100*(1-alpha) 
%       (Default: 0.05 - Corresponding to a 95% credible band)
%
% Outputs:
%   pfSamples - False alarm probabilities at which the bootstrapped ROC
%       curves are evaluated
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
%   prtScoreRocBayesianBootstrap(ds, y)


[ds,y,classLabels] = prtUtilScoreParseFirstTwoInputs(ds,y);

%% Default arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3 || isempty(nBootStrapSamples)
    nBootStrapSamples = 1000;
end

if nargin < 4 || isempty(nPfSamples)
    nPfSamples = 500; % pfSamples = linspace(0,1,nPfSamples)'
end

if nargin < 5 || isempty(alpha)
    alpha = 0.05; % 95% Confidence interval
end

%% Error Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isreal(ds(:))
    error('prtScoreRocBayesianBootstrap requires input ds to be real');
end

if any(isnan(ds(:)))
    warning('prt:rocBayesianBootstrap:dsContainsNans','ds input to prtScoreRocBayesianBootstrap function contains NaNs; these are interpreted as "missing data".  \n The resulting ROC curve may not acheive Pd or Pfa = 1')
end

uY = unique(y(:));
if length(uY) ~= 2  
    error('prtScoreRocBayesianBootstrap requires only 2 unique classes; unique(y(:)) = %s\n',mat2str(unique(y(:))));
end

if length(ds) ~= length(y);
    error('length(ds) (%d) must equal length(y) (%d)',length(ds),length(y));
end

if numel(ds) ~= length(ds)
    error('ROCs can only be realized in a 2 class case')
end

% This handles cases where y is not [0,1] but has only two hypothesis. We
% assume 0 to be the lowest unique Y since unique() sorts the outputs.
newY = y;
newY(y==uY(1)) = 0;
newY(y==uY(2)) = 1;
y = newY;
y = y(:); % Make sure y is a column

%% Initial Conveniences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dsH1 = ds(y==1);
dsH0 = ds(y==0);

pfSamples = linspace(0,1,nPfSamples)';
nH1 = length(dsH1);
nH0 = length(dsH0);

%% Bayesian Bootstrap 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

isNSamplesTooBig = length(y) > 2000; % Arbitrary big size. Probably a 1000 x 1000 matrix that you would have to make.

if isNSamplesTooBig
    % This is a way Kenny wrote so that you don't have to make the nH1 by
    % nH0 matrix. Although it is slower
    
    % Initialize
    Z = zeros(size(dsH1));
    sortedCDsH0 = sort(dsH0); 
    pds = zeros(nPfSamples, nBootStrapSamples);
    for iter = 1:nBootStrapSamples
    
        % Step 1
        cH0Weights = prtRvUtilDirichletDraw(ones(1,nH0),1);% Note that these weights are relative to the sorted indicies but since the dirichlet is symetric it doesn't matter.
        for iH1 = 1:nH1
            Z(iH1) = sum((sortedCDsH0 > dsH1(iH1)).*cH0Weights(:));
        end

        % Step 2
        cZWeights = prtRvUtilDirichletDraw(ones(1,nH1),1);% Note that these weights are relative to the sorted indicies but since the dirichlet is symetric it doesn't matter.
        sortedZ = sort(Z);
        for iPf = 1:length(pfSamples)
            pds(iPf,iter) = sum((sortedZ <= pfSamples(iPf)).*cZWeights(:));
        end
    end
    
else
    % This is the version from the appendix of Gu et al. It is faster but a
    % memory hog.
    pds = zeros(nPfSamples, nBootStrapSamples);
    
    xyComparison = repmat(dsH0(:),1,nH1) > repmat(dsH1(:)',nH0,1);
    bigTMatrix = repmat(pfSamples(:)', nH1,1);
    ot = ones(nPfSamples,1);
    for iter = 1:nBootStrapSamples
    
        % Step 1
        p = prtRvUtilDirichletDraw(ones(1,nH0),1);
        z = p*xyComparison;

        % Step 2
        q = prtRvUtilDirichletDraw(ones(1,nH1),1);
        pds(:,iter) = q*(z'*ot' < bigTMatrix);
    end
end
    
    
pds(pds>1) = 1; % Because of numerics from dirichlet weight generation 1.000001 is possible.

%% Credible Band Calculation

pdMean = mean(pds,2);

logistic = @(x)log(x./(1-x));
inverseLogistic = @(x)1./(1+exp(-x));

smallNum = 1e-12;

% We have to clean up the data so we don't make log mad
pdsClean = pds;
pdsClean(pdsClean==1) = 1-smallNum;
pdsClean(pdsClean==0) = smallNum;

pdMeanClean = pdMean;
pdMeanClean(pdMeanClean==1) = 1-smallNum;
pdMeanClean(pdMeanClean==0) = smallNum;

% Calculate error
eta = bsxfun(@minus,logistic(pdsClean),logistic(pdMeanClean));

% Now at every PF sample (row) we want the 1-alpha percentile of eta
% We use alpha/2 to center the interval
% Then add back in the ROC mean (in logistic space),
% Then we go back to ROC space using the inverse logistic
pdConfRegion = inverseLogistic(bsxfun(@plus,prctile(eta,100*[alpha/2, 1-alpha/2],2), logistic(pdMeanClean)));

%% Package Outputs
if nargout == 0
    prtUtilPlotRocConfidence(pfSamples,pdMean,pdConfRegion)
else
    varargout = {pfSamples, pdMean, pdConfRegion, pds};
end
