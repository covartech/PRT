classdef prtRvKde < prtRv
    % prtRvKde - Gaussian Kernel Density Estimation Random Variable 
    %   Assumes independence between each of the dimensions.
    %
    %   RV = prtRvKde creates a prtRvKde object with empty trainingData and
    %   bandwidths parameters. The trainingData must be set either directly
    %   or by calling the MLE method.
    %
    %   RV = prtRvKde('bandwidthMode', VALUE) enforces the bandwidths to be 
    %   determined either using 'manual' or 'diffusion'. Setting this
    %   property to 'manual' requires that the bandwidths also be
    %   sepecified. The default, 'diffusion', uses the automatic bandwidth
    %   selection method discussed in
    %
    %   Botev et al., Kernel density estimation via diffusion,
    %   Ann. Statist. Volume 38, Number 5 (2010), 2916-2957. 
    %   http://projecteuclid.org/DPubS?service=UI&version=1.0&verb=Display&handle=euclid.aos/1281964340
    %
    %   RV = prtRvKde(PROPERTY1, VALUE1,...) creates a prtRvKde object RV
    %   with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvKde object inherits all properties from the prtRv class. In
    %   addition, it has the following properties:
    %
    %   bandwidthMode    - A string specifying the method by which the
    %                      bandwidths are determined. Possibilities
    %                      {'diffusion'}, 'manual'
    %   bandwidths       - The bandwidths of the kernels used in each
    %                      dimension of the kernel density estimate. These
    %                      are the diagonal values of the covariance matrix
    %                      for the RBF kernels.
    %   trainingData     - The training data used to determined the kernel
    %                      density estimate
    %   minimumBandwidth - Minium bandwidth that is aloud to be estimated.
    %                      Diffusion based estimation can correctly 
    %                      identify a discrete density and infer a very
    %                      small bandwidth. This is sometimes undesirable
    %                      and causes stability issues. The default value
    %                      is []. If this value is empty it is estimated
    %                      during MLE as max(std(X)/size(X,1),eps);.
    %   
    %  A prtRvKde object inherits all methods from the prtRv class. The MLE
    %  method can be used to estimate the distribution parameters from
    %  data.
    %
    %  Examples:
    %
    %   % Plot a 2D density 
    %   ds = prtDataGenOldFaithful;
    %   plotPdf(mle(prtRvKde,ds))
    %   % or using the static method
    %   prtRvKde.ezPlotPdf(ds)
    %
    %   % Diffusion bandwidth estimation can identify discrete densities
    %   plotPdf(mle(prtRvKde,[0; 0; 0; 1; 1; 1; 2; 2;]))
    %
    %   % Comparison to ksdensity (Statistics toolbox required)
    %   % ksdensity() is only for 1D data
    %   ds = prtDataGenUnimodal;
    %   subplot(2,1,1)
    %   plotPdf(mle(prtRvKde,ds.getObservations(:,1)))
    %   xlim([-5 5]), ylim([0 0.2])
    %   subplot(2,1,2)
    %   ksdensity(ds.getObservations(:,1))
    %   xlim([-5 5]), ylim([0 0.2])
    % 
    %   % Classification comparison on multi-modal data
    %   % We use a MAP classifier with three different RVs
    %   ds = prtDataGenBimodal;
    %
    %   outputKde = kfolds(prtClassMap('rvs',prtRvKde),ds,5);
    %   outputMvn = kfolds(prtClassMap('rvs',prtRvMvn),ds,5);
    %   outputGmm = kfolds(prtClassMap('rvs',prtRvGmm('nComponents',2)),ds,5);
    %
    %   [pfKde,pdKde] = prtScoreRoc(outputKde);
    %   [pfMvn,pdMvn] = prtScoreRoc(outputMvn);
    %   [pfGmm,pdGmm] = prtScoreRoc(outputGmm);
    %
    %   plot(pfMvn,pdMvn,pfGmm,pdGmm,pfKde,pdKde)
    %   grid on
    %   xlabel('PF')
    %   ylabel('PD')
    %   title('Comparison of MAP Classification With Different RVs')
    %   legend({'MAP - MVN','MAP - GMM(2)','MAP - KDE'},'Location','SouthEast')
    %
    %   See also: prtRv, prtRvMvn, prtRvGmm, prtRvMultinomial,
    %   prtRvUniform, prtRvUniformImproper, prtRvVq

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


    properties (SetAccess = private)
        name = 'Kernel Density Estimation RV'
        nameAbbreviation = 'RVKDE';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end        
    
    properties
        bandwidthMode = 'diffusion';
        bandwidths = []; % Will be estimated
        trainingData = []% Locations of kernels
        minimumBandwidth = [];
    end
    
    properties (Dependent = true, Hidden=true)
        nDimensions
    end
    
    methods
        % The Constructor
        function R = prtRvKde(varargin)
            R = constructorInputParse(R,varargin{:});
        end

        function val = get.nDimensions(R)
            if R.isValid
                val = size(R.trainingData,2);
            else
                val = [];
            end
        end
        
        function R = set.bandwidthMode(R,val)
            assert(ischar(val),'bandwidthMode must be a string that is either, manual, or diffusion.');
            
            val = lower(val);
            
            % Limit the options for the covariance structure
            if ~(strcmpi(val,'manual') || strcmpi(val,'diffusion'))
                error('prt:prtRvKde:invalidBandwidthMode','%s is not a valid bandwidthMode. Possiblities are, manual, and diffusion',val);
            end
            
            R.bandwidthMode = val;
        end
        
        function R = set.minimumBandwidth(R,val)
            assert(isempty(val) | (isnumeric(val) && numel(val)==1 && val>=0),'minimumBandwidth must be empty or a scalar, numeric, non-negative value');
            R.minimumBandwidth = val;
        end
        
        function R = mle(R,X)
            X = R.dataInputParse(X); % Basic error checking etc
            
            if isempty(X)
                error('prt:prtRvKde','prtRvKde.mle() requires non-empty X');
            end
            
            R.trainingData = X;
            
            switch R.bandwidthMode
                case 'manual'
                    % Nothing to do assume set and do error check to make
                    % sure
                    assert(~isempty(R.bandwidths),'When bandwidthMode is ''manual'', bandwidths must be set before calling mle().');
                    assert(numel(R.bandwidths)==size(X,2),'The number of specified bandwidths for this RV does not match the dimensionality of the training data.');
                case 'diffusion'
                    nDims = size(X,2);
                    if nDims == 1
                        % 1D solution from Botev et al. 2010
                        R.bandwidths = prtExternal.kde.kde(X).^2;
                    elseif nDims == 2
                        % 2D solution from Botev et al. 2010
                        R.bandwidths = prtExternal.kde2d.kde2d(X).^2;
                    else
                        % In higher than 2 dimensions we assume independence in selecting
                        % bandwidths and use the 1D solution from Botev et al. 2010
                        % This is not entirely "best"
                        R.bandwidths = zeros(1,nDims);
                        for iDim = 1:nDims;
                            R.bandwidths(iDim) = prtExternal.kde.kde(X(:,iDim)).^2;
                        end
                    end
                otherwise
                    error('prt:prtRvKde:unknownBandwidthMode','Unknown bandwidth mode %s.',R.bandwidthMode);
            end
            
            if isempty(R.minimumBandwidth)
                % Estimate a minimum bandwidth using a heuristic method
                % Robust std estimate in each dim
                minBandwidthsStd = zeros(size(X,2),1);
                for iDim = 1:size(X,2)
                    cX = X(:,iDim);
                    cX(isnan(cX)) = []; % Remove nans
                    
                    % Calculate quantiles
                    sortedX = sort(cX,'ascend');
                    cCdf = cumsum(ones(size(cX)))./size(cX,1); 
                    
                    cXMiddle = sortedX(find(cCdf>0.25,1,'first'):find(cCdf>0.75,1,'first'));
                    
                    if isempty(cXMiddle)
                        minBandwidthsStd(iDim) = std(cX);
                    else
                        minBandwidthsStd(iDim) = std(cXMiddle);
                    end
                end
                % The optimal bandwidth for a gaussian uses this function
                % of a robust std estimate and the number of samples
                minBandwidthsStd = minBandwidthsStd * (4/(3*size(X,1)))^(1/5);
                
                % To make this a minumum we divide by 10
                % (and make it a variance) but never below eps
                minimumBandwidthVal = max((minBandwidthsStd(:)'/10).^2,eps);
                
            else
                minimumBandwidthVal = R.minimumBandwidth;
            end
            
            R.bandwidths = max(R.bandwidths,minimumBandwidthVal);
        end
        
        function vals = cdf(R,X)
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'CDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            nDims = size(X,2);
            nTrainingPoints = size(R.trainingData,1); 
            
            largestMatrixSize = prtOptionsGet('prtOptionsComputation','largestMatrixSize');
            memChunkSize = max(floor(largestMatrixSize/nTrainingPoints),1);
            
            vals = zeros(size(X,1),1);
            
            
            for iBlockStart = 1:memChunkSize:size(X,1);
                cInds = iBlockStart:min(iBlockStart+memChunkSize,size(X,1));
                
                cNSamples = length(cInds);
                
                cCdf = ones(cNSamples,1);
                for iDim = 1:nDims
                    cZscore = bsxfun(@minus,X(cInds,iDim),R.trainingData(:,iDim)')/R.bandwidths(iDim);
                    cCdf = cCdf .* mean(prtRvUtilNormCdf(cZscore,0,1),2);
                end
                vals(cInds) = cCdf;
            end

        end
        function vals = pdf(R,X)
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'PDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            vals = exp(logPdf(R,X));
        end
        
        function vals = logPdf(R,X)
            [isValid, reasonStr] = R.isValid;
            assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            X = R.dataInputParse(X); % Basic error checking etc
            
            
            nDims = size(X,2);
            nTrainingPoints = size(R.trainingData,1); 
            
            largestMatrixSize = prtOptionsGet('prtOptionsComputation','largestMatrixSize');
            memChunkSize = max(floor(largestMatrixSize/nTrainingPoints),1);
            
            vals = zeros(size(X,1),1);
            for iBlockStart = 1:memChunkSize:size(X,1);
                cInds = iBlockStart:min(iBlockStart+memChunkSize,size(X,1));
                
                cNSamples = length(cInds);
                
                cDist = zeros(cNSamples,size(R.trainingData,1));
                for iDim = 1:nDims
                    cDist = cDist + (bsxfun(@minus,X(cInds,iDim),R.trainingData(:,iDim)').^2) / (R.bandwidths(iDim));
                end
                
                %vals(cInds) = prtUtilSumExp(((-cDist.^2)/2 - 0.5*log(2*pi) - 0.5*sum(log(R.bandwidths)))')' - log(nTrainingPoints);
                vals(cInds) = prtUtilSumExp(((-cDist)/2 - 0.5*log(2*pi) - 0.5*sum(log(R.bandwidths)))')' - log(nTrainingPoints);
                
            end
        end
        
        function vals = draw(R,N)
            if nargin < 2 || isempty(N)
                N = 1;
            end
            
            assert(numel(N)==1 && N==floor(N) && N > 0,'N must be a positive integer scalar.')
                
            % Uniformly bootstrap the data and add mvn noise with variances
            % equal to the bandwidths
            vals = prtRvUtilRandomSample(size(R.trainingData,1),N,R.trainingData) + prtRvUtilMvnDraw(zeros(1,size(R.trainingData,2)),R.bandwidths,N);
        end
    end
    
    methods (Hidden = true)
        function [val, reasonStr] = isValid(R)
            if numel(R) > 1
                val = false(size(R));
                for iR = 1:numel(R)
                    [val(iR), reasonStr] = isValid(R(iR));
                end
                return
            end
            
            val = ~isempty(R.trainingData) & ~isempty(R.bandwidths);
            
            if val
                reasonStr = '';
            else
                badTrainingData = isempty(R.trainingData);
                badBandwidths = isempty(R.bandwidths);
                
                if badTrainingData && ~badBandwidths
                    reasonStr = 'because trainingData has not been set';
                elseif ~badTrainingData && badBandwidths
                    reasonStr = 'because bandwidths has not been set';
                elseif badTrainingData && badBandwidths
                    reasonStr = 'because trainingData and bandwidths have not been set';
                else
                    reasonStr = 'because of an unknown reason';
                end
            end
            
        end
        function val = plotLimits(R)
            % We use the minimum and maximum of the training data with an
            % additional 10% on each side.
            
            minX = min(R.trainingData,[],1);
            maxX = max(R.trainingData,[],1);
            
            rangeX = maxX-minX;
            
            val = zeros(1,2*R.nDimensions);
            val(1:2:R.nDimensions*2-1) = minX - rangeX/10;
            val(2:2:R.nDimensions*2) = maxX + rangeX/10;
        end
    end
    
    methods (Static)
        function ezPlotPdf(X)
            plotPdf(mle(prtRvKde,X));
        end
    end
    
    methods
        function varargout = plotPdf(R,varargin)
            % Plot the pdf
            %
            % This is overloaded from prtRv because we want to enforce that
            % the training data is included in the evaluated points
            % This ensures that when very small bandwidths are present
            % the plot still looks as expected.
            
            varargout = {};
            if R.isPlottable
                
                if nargin > 1 % Calculate appropriate limits from covariance
                    plotLims = varargin{1};
                else
                    plotLims = plotLimits(R);
                end
                
                tooBigNObservations = [2000 500 100];
                if size(R.trainingData,1) > tooBigNObservations(size(R.trainingData,2))
                    [linGrid,gridSize] = prtPlotUtilGenerateGrid(plotLims(1:2:end), plotLims(2:2:end), R.plotOptions.nSamplesPerDim);
                else
                    [linGrid,gridSize] = prtPlotUtilGenerateGrid(plotLims(1:2:end), plotLims(2:2:end), R.plotOptions.nSamplesPerDim, R.trainingData);
                end
                
                imageHandle = prtPlotUtilPlotGriddedEvaledFunction(R.pdf(linGrid), linGrid, gridSize, R.plotOptions.colorMapFunction(R.plotOptions.nColorMapSamples));
                
                if nargout
                    varargout = {imageHandle};
                end
            else
                [isValid, reasonStr] = R.isValid;
                if isValid
                    error('prt:prtRv:plot','This RV object cannont be plotted because it has too many dimensions.')
                else
                    error('prt:prtRv:plot','This RV object cannot be plotted. It is not yet valid %s.',reasonStr);
                end
            end
        end
    end
    
end
