%% prtRv
%
% Abstract class for prtRv Objects

classdef prtRv
    properties (Abstract = true, Hidden = true, Dependent = true)
        nDimensions % The number of dimensions
        isValid     % XXX ?
        isPlottable % Whether or not the Random variable is plottable
        displayName % The name displayed
    end % properties (Abstract = true, Hidden = true, Dependent = true)
methods
        % These functions are default "error" functions incase a
        % subclass has not specified these standard methods.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function vals = pdf(R,X) %#ok
            missingMethodError(R,'pdf');
        end % function pdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function vals = logPdf(R,X) %#ok
            missingMethodError(R,'logPdf');
        end % function logPdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function vals = cdf(R,X) %#ok
            missingMethodError(R,'cdf');
        end % function cdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function vals = draw(R,N) %#ok
            missingMethodError(R,'draw');
        end % function draw
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = mle(R,X) %#ok
            % Maximum likelihood estimate
            missingMethodError(R,'mle');
        end % function mle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = weightedMle(R,X,weights) %#ok
            missingMethodError(R,'weightedMle');
        end % function mle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function vals = kld(R1,R2) %#ok
            missingMethodError(R1,'kld');
        end % function kld
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = monteCarloCovariance(R,nSamples)
            % Calculates the sample covariance of drawn data
            if nargin < 2 || isempty(nSamples)
                nSamples = 1e3;
            end
            val = cov(draw(R,nSamples));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = monteCarloMean(R,nSamples)
            % Calculates the sample mean of drawn data
            if nargin < 2 || isempty(nSamples)
                nSamples = 1e3;
            end
            val = mean(draw(R,nSamples));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % As a default we just use the monte carlo limits.
        % If a sub-class implements plotLimits ezPdfPlot or ezCdfPlot
        % should use that.
        function limits = plotLimits(R)
   
            limits = monteCarloPlotLimits(R);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function limits = monteCarloPlotLimits(R,nStds,nSamples)
            % Calculate plotting limits
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % These functions are default plotting functions
        % They determine plotting limits automatically using monte carlo
        % estimates of the mean and covariance
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function ezPdfPlot(R,varargin)
            if R.isPlottable
                userDefinedLimits = true;
                if nargin > 1 % Calculate appropriate limits from covariance
                    limits = plotLimits(R);
                    userDefinedLimits = false;
                end
                
                switch R.nDimensions
                    case 1
                        if userDefinedLimits
                            ezplot(@(x)R.pdf(x),varargin{:});
                        else
                            ezplot(@(x)R.pdf(x),limits);
                        end
                        title('');
                        xlabel('');
                    case 2
                        % This is a little bit of a hack so that we don't
                        % have to pick the limits
                        if userDefinedLimits
                            ezsurf(@(x,y)R.pdf([x,y]),varargin{:});
                        else
                            ezsurf(@(x,y)R.pdf([x,y]),limits);
                        end
                        xData = get(get(gca,'Children'),'xdata');
                        yData = get(get(gca,'Children'),'ydata');
                        zData = get(get(gca,'Children'),'zdata');
                        imagesc(xData(1,:),yData(:,1),zData)
                        axis xy;
%                     case 3 % Maybe later
                end
            else
                if R.isValid
                    error('prtRv object has too many dimensions for plotting.')
                else
                    error('prtRv object is not yet a valid random variable.');
                end
            end
        end % function ezPdfPlot
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function ezCdfPlot(R,varargin)
            if R.isPlottable
                userDefinedLimits = true;
                if nargin > 1 % Calculate appropriate limits from covariance
                    limits = plotLimits(R);
                    userDefinedLimits = false;
                end
                switch R.nDimensions
                    case 1
                        if userDefinedLimits
                            ezplot(@(x)R.cdf(x),varargin{:});
                        else
                            ezplot(@(x)R.cdf(x),limits);
                        end
                        ylim([0 1]);
                        title('');
                        xlabel('');
                    case 2
                        if userDefinedLimits
                            ezsurf(@(x,y)R.cdf([x,y]),varargin{:});
                        else
                            ezsurf(@(x,y)R.cdf([x,y]),limits);
                        end
                        xData = get(get(gca,'Children'),'xdata');
                        yData = get(get(gca,'Children'),'ydata');
                        zData = get(get(gca,'Children'),'zdata');
                        imagesc(xData(1,:),yData(:,1),zData)
                        axis xy;
                     % case 3 % Maybe later
                end
            else
                if R.isValid
                    error('This RV object has too many dimensions for plotting.')
                else
                    error('This RV object is not yet valid.');
                end
            end
        end % function ezCdfPlot
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function display(R,inName)
            if nargin < 2 || isempty(inName)
                inName = inputname(1);
            end
            
            fprintf('%s = \n',inName)
            if numel(R) > 1
                dimString = sprintf('%dx',size(R)');
                dimString = dimString(1:end-1);

                fprintf('\t%s array of %s objects \n',dimString,R(1).displayName)
            else
                fprintf('\tA %s \n',R.displayName)
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end % methods
    methods (Access = 'private', Hidden = true)
        function missingMethodError(R,methodName)
            error('The method %s is not defined for %s objects',methodName,R.displayName);
        end
    end
end % classdef

