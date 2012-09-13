classdef prtDataSetRegress < prtDataSetStandard
    % prtDataSetRegress   Data set object for regression
    %
    %   DATASET = prtDataSetRegress returns a prtDataSetRegress object
    %
    %   DATASET = prtDataSetRegress(PROPERTY1, VALUE1, ...) constructs a
    %   prtDataSetRegress object DATASET with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtDataSetRegress object inherits all properties from the
    %   prtDataSetStandard class. 
    %
    %   A prtDataSetRegress inherits all methods from the
    %   prtDataSetStandard object. In addition it overloads the following
    %   functions:
    %
    %   plot      - Plot the prtDataSetRegress object
    %   summarize - Summarize the prtDataSetRegress object.
    % 
    %   See also: prtDataSetStandard, prtDataSetClass, prtDataSetBase
    
    properties (Hidden = true)
        plotOptions = prtDataSetRegress.initializePlotOptions()
    end
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetRegress(varargin)
  
            prtDataSet = prtDataSet@prtDataSetStandard(varargin{:});
        end
        
        function varargout = plot(obj, featureIndices)
            % Plot   Plot the prtDataSetRegress object
            %
            %   dataSet.plot() Plots the prtDataSetRegress object.
            
            if ~obj.isLabeled
                obj = obj.setTargets(zeros(obj.nObservations,1));
            end
            
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
            elseif nPlotDimensions >= 2
                error('prt:plot:NoPlotDimensionality','Regression plots are currently only valid for 1 dimensional data, but the requested plot has %d dimensions',nPlotDimensions);
            end
            
            holdState = get(gca,'nextPlot');
            
            classColors = obj.plotOptions.colorsFunction(1);
            markerSize = obj.plotOptions.symbolSize;
            lineWidth = obj.plotOptions.symbolLineWidth;
            classSymbols = obj.plotOptions.symbolsFunction(1);
            
            iPlot = 1;
            classEdgeColor = obj.plotOptions.symbolEdgeModificationFunction(classColors(iPlot,:));
            
            h = plot(obj.getObservations(:,featureIndices),obj.getTargets, classSymbols(iPlot), 'MarkerFaceColor', classColors(iPlot,:), 'MarkerEdgeColor', classEdgeColor,'linewidth',lineWidth,'MarkerSize',markerSize);
            
            set(gca,'nextPlot',holdState);
            
            % Set title
            title(obj.name);
            switch nPlotDimensions
                case 1
                    xlabel(obj.getFeatureNames(featureIndices));
                    ylabel(obj.getTargetNames(1));
                otherwise
                    error('prt:plot:NoPlotDimensionality','Regression plots are currently only valid for 1 dimensional data, but DataSet has %d dimensions',obj.nFeatures);
            end
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {h};
            end
        end
	end
	
    methods (Static, Hidden = true)
        function plotOptions = initializePlotOptions()
            plotOptions = prtOptionsGet('prtOptionsDataSetRegressPlot');
        end
	end
	
	methods (Static)
		function obj = loadobj(obj)
			
			if isstruct(obj)
				if ~isfield(obj,'version')
					% Version 0 - we didn't even specify version
					inputVersion = 0;
				else
					inputVersion = obj.version;
				end
				
				currentVersionObj = prtDataSetRegress;
				
				if inputVersion == currentVersionObj.version
					% Returning now will cause MATLAB to ignore this entire
					% loadobj() function and perform the default actions
					return
				end
				
				if inputVersion > currentVersionObj.version
					% Versions new than current version!
					warning('prt:prtDataSetRegress:loadNewVersion','Attempt to load an updated prtDataSetRegress from file. This prtDataSetRegress was saved using a new version of the PRT. This dataset may not load properly.')
					return
				end
				
				if inputVersion < 2
					% Versions older than 2 are no longer supported.
					warning('prt:prtDataSetRegress:loadOldVersion','Attempt to load obsolete prtDataSetRegress from file. This prtDataSetRegress may not load properly.')
					return
				end
				
				inObj = obj;
				obj = currentVersionObj;
				switch inputVersion
					case 2
						obj = obj.setObservationsAndTargets(inObj.internalData ,inObj.internalTargets);
						obj.observationInfo = inObj.observationInfoInternal;
						
						if ~isempty(inObj.featureInfoInternal);
							obj.featureInfo = inObj.featureInfoInternal;
						end
						
						if ~isempty(inObj.featureNameIntegerAssocArray)
							obj = obj.setFeatureNames(inObj.featureNameIntegerAssocArray.cellValues,inObj.featureNameIntegerAssocArray.integerKeys);
						end
						
						if ~isempty(inObj.observationNamesInternal.cellValues)
							obj = obj.setObservationNames(inObj.observationNamesInternal.cellValues,inObj.observationNamesInternal.integerKeys);
						end
						
						if ~isempty(inObj.targetNamesInternal)
							obj = obj.setTargetNames(inObj.targetNamesInternal.cellValues);
						end
						
						obj.name = inObj.name;
						obj.description = inObj.description;
						obj.userData = inObj.userData;
				end
				
			else
				% Nothin special
			end
		end
	end
end
