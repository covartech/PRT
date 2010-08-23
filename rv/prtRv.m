%% prtRv
%
% Abstract class for prtRv Objects

classdef prtRv
    properties (Abstract = true, Hidden = true, Dependent = true)
        nDimensions
        isValid
        isPlottable
    end
    properties (Abstract = true, Hidden = true)
        displayName
    end
    
    properties (Hidden = true)
        PlotOptions = prtRv.initializePlotOptions();
    end
    
    methods
        % These functions are default "error" functions incase a
        % subclass has not specified these standard methods.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = pdf(R,X) %#ok
            missingMethodError(R,'pdf');
        end
        
        function vals = logPdf(R,X) %#ok
            missingMethodError(R,'logPdf');
        end
        
        function vals = cdf(R,X) %#ok
            missingMethodError(R,'cdf');
        end
        
        function vals = draw(R,N) %#ok
            missingMethodError(R,'draw');
        end
        
        function vals = mle(R,X) %#ok
            missingMethodError(R,'mle');
        end
        
        function vals = weightedMle(R,X,weights) %#ok
            missingMethodError(R,'weightedMle');
        end
        
        function initMembershipMat = initializeMixtureMembership(Rs,X,weights) %#ok
            missingMethodError(R,'initializeMixtureMembership');
        end
        
        function vals = kld(R1,R2) %#ok
            missingMethodError(R1,'kld');
        end
    end
    
    methods
        function val = monteCarloCovariance(R,nSamples)
            % Calculates the sample covariance of drawn data
            if nargin < 2 || isempty(nSamples)
                nSamples = 1e3;
            end
            val = cov(draw(R,nSamples));
        end
        
        function val = monteCarloMean(R,nSamples)
            % Calculates the sample mean of drawn data
            if nargin < 2 || isempty(nSamples)
                nSamples = 1e3;
            end
            val = mean(draw(R,nSamples));
        end
        
        function limits = plotLimits(R)
            % As a default we just use the monte carlo limits.
            % If a sub-class implements plotLimits ezPdfPlot or ezCdfPlot
            % will use that.
            limits = monteCarloPlotLimits(R);
        end
        
        function limits = monteCarloPlotLimits(R,nStds,nSamples)
            % Calculate nice plotting limits
            if nargin < 2 || isempty(nStds)
                nStds = 2;
            end
            if nargin < 3 || isempty(nSamples)
                nSamples = []; % Let the defaults from monteCarloMean and
                % monteCarloCovariance decide.
            end
            
            mu = monteCarloMean(R,nSamples);
            C = monteCarloCovariance(R,nSamples);
            
            minX = min(mu, [], 1)' - nStds*sqrt(diag(C));
            maxX = max(mu, [], 1)' + nStds*sqrt(diag(C));
            
            limits = zeros(1,2*length(minX));
            limits(1:2:end) = minX;
            limits(2:2:end) = maxX;
        end
        
        function ezPdfPlot(R,limits)
            if R.isPlottable
                if nargin < 2
                    limits = plotLimits(R);
                end
                
                [linGrid, gridSize] = prtPlotUtilGenerateGrid(limits(2:2:end), limits(1:2:end), R.PlotOptions.nSamplesPerDim);
                
                pdfSamples = reshape(R.pdf(linGrid),gridSize);
                
                imageHandle = prtPlotUtilPlotGriddedEvaledFunction(pdfSamples, linGrid, gridSize, R.PlotOptions.colorMapFunction(256));
                
            else
                if R.isValid
                    error('prtRv object has too many dimensions for plotting.')
                else
                    error('prtRv object is not yet fully defined.');
                end
            end
        end
        
        function ezCdfPlot(R,varargin)
            if R.isPlottable
                if nargin < 2
                    limits = plotLimits(R);
                end
                
                [linGrid, gridSize] = prtPlotUtilGenerateGrid(limits(2:2:end), limits(1:2:end), R.PlotOptions.nSamplesPerDim);
                
                cdfSamples = reshape(R.cdf(linGrid),gridSize);
                
                imageHandle = prtPlotUtilPlotGriddedEvaledFunction(cdfSamples, linGrid, gridSize, R.PlotOptions.colorMapFunction(256));
                
            else
                if R.isValid
                    error('prtRv object has too many dimensions for plotting.')
                else
                    error('prtRv object is not yet fully defined.');
                end
            end
        end

%         function display(R,inName)
%             if nargin < 2 || isempty(inName)
%                 inName = inputname(1);
%             end
%             
%             fprintf('%s = \n',inName)
%             if numel(R) > 1
%                 dimString = sprintf('%dx',size(R)');
%                 dimString = dimString(1:end-1);
%                 
%                 fprintf('\t%s array of %s objects \n',dimString,R(1).displayName)
%             else
%                 fprintf('\tA %s \n',R.displayName)
%             end
%         end
    end
    
    methods (Access = 'private', Hidden = true)
        function missingMethodError(R,methodName)
            error('The method %s is not defined for %s objects',methodName,R.displayName);
        end
    end
    
    methods (Static)
        function PlotOptions = initializePlotOptions()
            UserOptions = prtUserOptions;
            PlotOptions = UserOptions.RvPlotOptions;
        end
    end
    
end

