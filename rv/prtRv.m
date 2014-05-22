classdef prtRv < prtAction
    % prtRv Base class for all prt random variables
    %
    %   This is an abstract class from which all prt random variables
    %   inherit. It can not be instantiated. prtRv contains the following 
    %   properties:
    %
    %   name           - Name of the random variable.
    %   userData       - Structure for holding additional related to the
    %                    random variable.
    %   nDimensions    - Number of dimensions of the vector space
    %                    represented by the random variable.
    %
    %   The prtRv class has the following methods
    %
    %   plotPdf - Plot the pdf of the random variable
    %   plotCdf - Plot the cdf of the random variable
    %
    %   The prtRv class has the following methods, most of which are
    %   overloaded. If a method is not overloaded, it is because it is not
    %   possible to implement the functionality.
    %
    %   pdf - Output the pdf of the random variable evaluated at the points
    %         specified
    %
    %   logPdf - Output the log-pdf of the random variable evaluated at the
    %            points specified (for many distributions, this can be
    %            calculated more easily than simply log(pdf(R,X))
    %
    %   cdf - Output the cdf of the random variable evaluated at the
    %         points specified
    %
    %   draw - Draw samples from the random variable
    %
    %   mle - Perform maximum likelihood estimation of the objects parameters 
    %         using the specified data
    %
    %   See also: prtRvMvn, prtRvGmm, prtRvMultinomial, prtRvUniform,
    %   prtRvUniformImproper, prtRvVq

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


    properties
        plotOptions  = prtRv.initializePlotOptions()
    end
    properties (Abstract = true, Hidden = true, Dependent = true)
        nDimensions % The number of dimensions
    end
    methods (Abstract, Hidden=true)
        [bool, reasonStr] = isValid(R)
    end
    methods
        % These functions are default "error" functions incase a
        % subclass has not specified these standard methods.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = pdf(R,X) %#ok
            % PDF Output the pdf of the random variable evaluated at the points specified
            %
            % pdf = RV.pdf(X) returns the value of the pdf of the prtRv
            % object evaluated at X. X must be an N x nDims matrix, where N
            % is the number of locations to evaluate the pdf, and nDims is
            % the same as the number of dimensions, nDimensions, of the
            % prtRv object RV.
            missingMethodError(R,'pdf');
        end

        function vals = logPdf(R,X)
            % LOGPDF Output the log pdf of the random variable evaluated at the points specified
            %
            % logpdf = RV.logpdf(X) returns the logarithm of value of the
            % pdf of the prtRv object evaluated at X. X must be an N x
            % nDims matrix, where N is the number of locations to evaluate
            % the pdf, and nDims is the same as the number of dimensions,
            % nDimensions, of the prtRv object RV.
            vals = log(R.pdf(X));
        end
        
        function vals = cdf(R,X) %#ok
            % CDF Output the cdf of the random variable evaluated at the points specified
            %
            % cdf = RV.cdf(X) returns the value of the cdf of the prtRv
            % object evaluated at X. X must be an N x nDims matrix, where
            % N is the number of locations to evaluate the pdf, and nDims
            % is the same as the number of dimensions, nDimensions, of the
            % prtRv object RV.

            missingMethodError(R,'cdf');
        end
        
        function vals = draw(R,N) %#ok
            % DRAW  Draw random samples from the distribution described by the prtRv object
            %
            % VAL = RV.draw(N) generates N random samples drawn from the
            % distribution described by the prtRv object RV. VAL will be a
            % N x nDimensions vector, where nDimensions is the number of
            % dimensions of RV.

            missingMethodError(R,'draw');
        end

        function vals = mle(R,X) %#ok
            % MLE Compute the maximum likelihood estimate 
            %
            % RV = RV.mle(X) computes the maximum likelihood estimate based
            % the data X. X should be nObservations x nDimensions.        
            missingMethodError(R,'mle');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % These functions are default plotting functions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function varargout = plotPdf(R,varargin)
            % PLOTPDF  Plot the pdf of the prtRv
            %
            % R.plotPdf()
            % R.plotPdf([xMin yMin (zMin) xMax yMax (zMax)]);  
            
            varargout = {};
            [isValid, reasonStr] = R.isValid;
            if R.isPlottable
                
                if nargin > 1 % Calculate appropriate limits from covariance
                    plotLims = varargin{1};
                else
                    plotLims = plotLimits(R);
                end
                
                [linGrid, gridSize] = prtPlotUtilGenerateGrid(plotLims(1:2:end), plotLims(2:2:end), R.plotOptions.nSamplesPerDim);
                
                imageHandle = prtPlotUtilPlotGriddedEvaledFunction(R.pdf(linGrid), linGrid, gridSize, R.plotOptions.colorMapFunction(R.plotOptions.nColorMapSamples));
                
                if nargout
                    varargout = {imageHandle};
                end
            else
                if isValid
                    error('prt:prtRv:plot','This RV object cannont be plotted because it has too many dimensions.')
                else
                    error('prt:prtRv:plot','This RV object cannot be plotted. This RV is not yet valid %s.',reasonStr);
                end
            end
        end
        function varargout = plotLogPdf(R,varargin)
            % plotLogPdf  Plot the pdf of the prtRv
            %
            % R.plotLogPdf()
            % R.plotLogPdf([xMin yMin (zMin) xMax yMax (zMax)]);  
            
            varargout = {};
            [isValid, reasonStr] = R.isValid;
            if R.isPlottable
                
                if nargin > 1 % Calculate appropriate limits from covariance
                    plotLims = varargin{1};
                else
                    plotLims = plotLimits(R);
                end
                
                [linGrid, gridSize] = prtPlotUtilGenerateGrid(plotLims(1:2:end), plotLims(2:2:end), R.plotOptions.nSamplesPerDim);
                
                imageHandle = prtPlotUtilPlotGriddedEvaledFunction(R.logPdf(linGrid), linGrid, gridSize, R.plotOptions.colorMapFunction(R.plotOptions.nColorMapSamples));
                
                if nargout
                    varargout = {imageHandle};
                end
            else
                if isValid
                    error('prt:prtRv:plot','This RV object cannont be plotted because it has too many dimensions.')
                else
                    error('prt:prtRv:plot','This RV object cannot be plotted. This RV is not yet valid %s.',reasonStr);
                end
            end
        end
        
        function varargout = plotCdf(R,varargin)
            %PLOTCDF Plot the cdf of the prtRv
            % R.plotCdf()
            % R.plotCdf([xMin yMin (zMin) xMax yMax (zMax)]);  
            
            varargout = {};
            [isValid, reasonStr] = R.isValid;
            if R.isPlottable
                
                if nargin > 1 % Calculate appropriate limits from covariance
                    plotLims = varargin{1};
                else
                    plotLims = plotLimits(R);
                end
                
                [linGrid,gridSize] = prtPlotUtilGenerateGrid(plotLims(1:2:end), plotLims(2:2:end), R.plotOptions.nSamplesPerDim);
                
                imageHandle = prtPlotUtilPlotGriddedEvaledFunction(R.cdf(linGrid), linGrid, gridSize, R.plotOptions.colorMapFunction(R.plotOptions.nColorMapSamples));
                
                if nargout
                    varargout = {imageHandle};
                end
            else
                if isValid
                    error('prt:prtRv:plot','This RV object cannont be plotted because it has too many dimensions for plotting.')
                else
                    error('prt:prtRv:plot','This RV object cannot be plotted. This RV is not yet valid %s.',reasonStr);
                end
            end
        end
    end
    
    methods (Hidden = true)
        % As a default we just use the monte carlo limits.
        % If a sub-class implements plotLimits ezPdfPlot or ezCdfPlot
        % should use that.
        function limits = plotLimits(R)
            limits = monteCarloPlotLimits(R);
        end
        
        function val = isPlottable(R)
            val = ~isempty(R.nDimensions) && R.nDimensions < 4 && R.isValid;
        end
    end
    
    methods (Access = protected, Hidden = true)
        function Obj = trainAction(Obj, DataSet)
            Obj = Obj.mle(DataSet);
        end
        
        function DataSet = runAction(Obj, DataSet)
            DataSet = DataSet.setObservations(Obj.logPdf(DataSet));
        end
        
        function xOut = runActionFast(Obj, xIn, ds) %#ok<INUSD>
            xOut = Obj.logPdf(xIn);
        end
    end
    
    
    methods (Access = 'private', Hidden = true)
        function missingMethodError(R,methodName) %#ok<MANU>
            error('The method %s is not defined for this prtRv object',methodName);
        end
    end
    methods (Access = 'private',Hidden = true,Static = true)
        function plotOptions = initializePlotOptions()
            if ~isdeployed
                plotOptions = prtOptionsGet('prtOptionsRvPlot');
            else
                plotOptions = prtOptions.prtOptionsRvPlot;
            end
        end
    end
    
    methods (Access = 'protected', Hidden = true)
        function X = dataInputParse(R,X) %#ok<MANU>
            % dataInputParse - Parse inputs for RVs that only require the
            % data. Since most RVs need only the observations (X). This
            % function allows RVs to operate on prtDataSetStandard()s and 
            % a data matrix.
            
            if isnumeric(X) || islogical(X)
                % Quick exit from this ifelse so we don't call isa
                % which can be slow
            elseif isa(X,'prtDataSetStandard')
                X = X.getObservations();
            else
                error('prt:prtRv','Input to mle() must be a matrix of data or a prtDataSet.');
            end
            
        end
        
        function R = constructorInputParse(R,varargin)
            
            nIn = length(varargin);

            % Quick Exit for the zero input constructor
            if nIn == 0
                return
            elseif mod(nIn,2)
                error('prt:prtRv:constructorInputParse','Inputs must be supplied by as string/value pairs');
            end
            
            R = prtUtilAssignStringValuePairs(R,varargin{:});

        end
        
        
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
    end
    methods (Hidden = true)
        function S = toStructure(obj)
            % toStructure(obj)
            % This default prtRv method adds all properties defined in
            % the class of obj into the structure, that are:
            %   GetAccess: public
            %   Hidden: false
            % other prtRvs (that are properties, contained in cells,
            %   or fields of structures) are also converted to structures.
            
            MetaInfo = meta.class.fromName(class(obj));
            
            propNames = {};
            for iProperty = 1:length(MetaInfo.Properties)
                if isequal(MetaInfo.Properties{iProperty}.DefiningClass,MetaInfo) && strcmpi(MetaInfo.Properties{iProperty}.GetAccess,'public') && ~MetaInfo.Properties{iProperty}.Hidden
                    propNames{end+1} = MetaInfo.Properties{iProperty}.Name; %#ok<AGROW>
                end
            end
            
            S.class = 'prtRv';
            S.prtRvType = class(obj);
            for iProp = 1:length(propNames)
                cProp = obj.(propNames{iProp});
                for icProp = 1:length(cProp) % Allow for arrays of objects
                    cOut = prtUtilFindPrtActionsAndConvertToStructures(cProp(icProp));
                    if icProp == 1
                        cVal = repmat(cOut,size(cProp));
                    else
                        cVal(icProp) = cOut;
                    end
                end
                S.(propNames{iProp}) = cVal;
            end
            S.userData = obj.userData;
        end
    end
end


