classdef prtDataSetUnLabeled < prtDataSetInMemory
    
    properties (Dependent, Hidden)
        % Additional properties for plotting
        plottingColors
        plottingSymbols
    end
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetUnLabeled(varargin)
            % prtDataSet = prtDataSetClass
            % prtDataSet = prtDataSetClass(prtDataSetClassIn, {paramName1, paramVal2, ...})
            % prtDataSet = prtDataSetClass(data, {paramName1, paramVal2, ...})
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Empty Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % prtDataSet = prtDataSetClass %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin == 0
                % Empty constructor
                % Nothing to do
                return
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % All Other Constructors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % prtDataSet = prtDataSetClass(prtDataSetIn, {paramName1, paramVal2, ...})
            % prtDataSet = prtDataSetClass(data, targets, {paramName1, paramVal2, ...})
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(varargin{1}, 'prtDataSetUnLabeled')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Copy Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetClass(prtDataSetClassIn, {paramName1, paramVal2, ...})
                % Will be the same as other constructors after this..
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
                
            elseif isa(varargin{1},'double')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Regular Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % prtDataSet = prtDataSetUnLabeled(data, {paramName1, paramVal2, ...})
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                prtDataSet.data = varargin{1};
                varargin = varargin(2:end);
                
            elseif isa(varargin{1},'prtDataSetBase')
                prtDataSet.data = varargin{1}.getObservations;
                prtDataSet.UserData = varargin{1}.UserData;
                prtDataSet.name = varargin{1}.name;
                prtDataSet.description = varargin{1}.description;
                varargin = varargin(2:end);
            end
            
            % At this point we have varargin as string value pairs and
            % prtDataSet with data and targets set
            
            % Quick exit if no more inputs.
            if isempty(varargin)
                return
            end
            
            % Check Parameter string, value pairs
            inputError = false;
            if mod(length(varargin),2)
                inputError = true;
            end
            paramNames = varargin(1:2:(end-1));
            if ~iscellstr(paramNames)
                inputError = true;
            end
            
            paramValues = varargin(2:2:end);
            if inputError
                error('prt:prtDataSetUnLabeled:invalidInputs','Additional input arguments must be specified as parameter string, value pairs.')
            end
            
            % Now we loop through and apply the properties
            for iPair = 1:length(paramNames)
                prtDataSet.(paramNames{iPair}) = paramValues{iPair};
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
    
    methods
       
        function colors = get.plottingColors(obj)
            colors = prtPlotUtilClassColors(obj.nUniqueTargets);
        end
        function symbols = get.plottingSymbols(obj)
            symbols = prtPlotUtilClassSymbols(obj.nUniqueTargets);
        end
        
        %PLOT:
        function varargout = plot(obj, featureIndices)
            
             if nargin < 2 || isempty(featureIndices)
                 featureIndices = 1:obj.nFeatures;
             end
             if islogical(featureIndices)
                 featureIndices = find(featureIndices);
             end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            end
            
            nClasses = 1;
            classColors = prtPlotUtilClassColors(nClasses);
            classSymbols = prtPlotUtilClassSymbols(nClasses);
            
            cX = obj.getObservations;
            classEdgeColor = prtDataSetBase.edgeColorMod(classColors);
            
            linewidth = .1;
            handleArray = prtDataSetBase.plotPoints(cX,obj.getFeatureNames(featureIndices),classSymbols,classColors,classEdgeColor,linewidth);
            
            % Set title
            title(obj.name);
                        
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,{}};
            end
        end
        
        
        function varargout = plotAsTimeSeries(obj,featureIndices)
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
           
            nClasses = 1;
            classColors = prtPlotUtilClassColors(nClasses);
            classSymbols = prtPlotUtilClassSymbols(nClasses);
            
            handleArray = zeros(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % Loop through classes and plot
            
            %Use "i" here because it's by uniquetargetIND
            cX = obj.getObservations;
            
            xInd = 1:size(cX,2);
            linewidth = .1;
            h = prtDataSetBase.plotLines(xInd,cX,classColors,linewidth);
            handleArray = h(1);

            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            % Create legend
            legendStrings = 'Unlabeled';
            legend(handleArray,legendStrings,'Location','SouthEast');
                        
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
    end
end
