classdef prtDataSetLabeledInMemory < prtDataSetLabeled & prtDataSetInMemory
    
    properties (Dependent)
        nObservations       % size(data,1)
        nFeatures           % size(data,2)
        nTargetDimensions   % size(targets,2)
    end
    
    % inherits: data, targets from prtDataSetInMemoryTemp
    
    methods
        function nObservations = get.nObservations(obj)
            nObservations = size(obj.data,1); %use InMem's .data field
        end
        function nFeatures = get.nFeatures(obj)
            nFeatures = size(obj.data,2);
        end
        
        function obj = joinObservations(obj, varargin)
            for iCat = 1:length(varargin)
                %note: use the protected .observationNames here to avoid 
                %building these cell arrays if they aren't already set (as opposed to
                %getObservationNames)
                obj = catObservations(obj, varargin{iCat}.getObservations, varargin{iCat}.observationNames);
            end
        end
        
        function obj = joinFeatures(obj, varargin)
            for iCat = 1:length(varargin)
                %note: use the protected .featureNames here to avoid 
                %building these cell arrays if they aren't already set (as opposed to
                %getFeatureNames)
                obj = catFeatures(obj, varargin{iCat}.getObservations, varargin{iCat}.featureNames);
            end
        end
        
        function obj = catFeatures(obj, newData, newFeatureNames)
            
            if nargin < 3
                newFeatureNames = {};
            elseif ~isempty(newFeatureNames)
                if ~iscellstr(newFeatureNames)
                    error('prt:prtDataSetInMemory:incorrectInput','newObsNames, must be a cellstr.');
                end
                if length(newFeatureNames) ~= size(newData,2)
                    error('prt:prtDataSetInMemory:incorrectInput','The number of features in the new data and the new f names do not match.');
                end
            end
            oldDim = obj.nFeatures;
            
            obj = catFeatures@prtDataSetInMemory(obj,newData); %inMemory
            obj = addFeatureNames(obj,newFeatureNames,oldDim); %dataSetBase
        end
        
        function obj = catObservations(obj, newData, newObsNames)
            if nargin < 3
                newObsNames = {};
            elseif ~isempty(newObsNames)
                if ~iscellstr(newObsNames)
                    error('prt:prtDataSetInMemory:incorrectInput','newObsNames, must be a cellstr.');
                end
                if length(newObsNames) ~= size(newData,1)
                    error('prt:prtDataSetInMemory:incorrectInput','The number of observations in the new data and the new observation names do not match.');
                end
            end
            
            if size(newData,2) ~= obj.nFeatures
                error('prt:prtDataSetInMemory:incorrectDimensionality','The dimensionality of the specified data (%d) does not match the dimensionality of this dataset (%d).', size(newData,2), obj.nFeatures);
            end
            
            oldN = obj.nObservations;
            
            obj = catObservations@prtDataSetInMemory(obj,newData);     %inMemory
            obj = addObservationNames(obj,newObsNames,oldN);           %dataSetBase
        end

        %Required by prtDataSetLabeled
        function targets = getTargets(obj,indices1,indices2)
            if nargin < 3
                indices2 = 1:obj.nTargetDimensions;
            end
            if nargin < 2
                indices1 = 1:obj.nObservations;
            end
            if max(indices1) > obj.nObservations
                error('prt:prtDataSetLabeledInMemory:incorrectInput','max(indices1) (%d) must be <= nObservations (%d)',max(indices1),obj.nObservations);
            end
            if max(indices2) > obj.nTargetDimensions
                error('prt:prtDataSetLabeledInMemory:incorrectInput','max(indices2) (%d) must be <= nTargetDimensions (%d)',max(indices1),obj.nTargetDimensions);
            end
            targets = obj.targets(indices1,indices2);
        end
        
        function obj = setTargets(obj,targets,indices1,indices2)
            if nargin < 4
                indices2 = 1:size(targets,2);
            end
            if nargin < 3
                indices1 = 1:obj.nObservations;
            end
            if max(indices1) > obj.nObservations
                error('prt:prtDataSetLabeledInMemory:incorrectInput','max(indices1) (%d) must be <= nObservations (%d)',max(indices1),obj.nObservations);
            end
            obj.targets(indices1,indices2) = targets;
        end
        
        function nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = size(obj.targets,2);
        end
        
        % PLOT has to go in class or regress, but should use
        % prtDataSetBase.plotPoints...
        %
        
        %         function varargout = plot(obj, featureIndices)
%             if nargin < 2 || isempty(featureIndices)
%                 featureIndices = 1:obj.nFeatures;
%             end
%             if islogical(featureIndices)
%                 featureIndices = find(featureIndices);
%             end
%             
%             nPlotDimensions = length(featureIndices);
%             if nPlotDimensions < 1
%                 warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
%                 return
%             end
%             if nPlotDimensions > 3
%                 error('prt:plot:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to selet and visualize a subset of the features.',nPlotDimensions);
%             end
%             if max(featureIndices) > obj.nFeatures
%                 error('prt:plot:plotDimensionality','A requested plot dimensions (%d) exceeds the dimensionality of the data set (%d).',max(featureIndices),obj.nFeatures);
%             end
%             
%             % Preserve the hold state of the figure
%             holdState = ishold;
%             
%             % This is a little weird. But it prevents us from duplicating
%             % this code so ...
%             % Get colors and symbols from the colors and symbols functions
%             isLabeled = ismethod(obj,'getTargets');
%             if isLabeled
%                 nClasses = obj.nUniqueTargets;
%                 classColors = obj.plottingColors;
%                 classSymbols = obj.plottingSymbols;
%             else
%                 nClasses = 1;
%                 classColors = prtPlotUtilClassColors(1);
%                 classSymbols = prtPlotUtilClassSymbols(1);
%             end
%             
%             
%             handleArray = zeros(nClasses,1);
%             % Loop through classes and plot
%             for i = 1:nClasses
%                 if isLabeled
%                     cX = obj.getObservationsByUniqueTargetInd(i, featureIndices);
%                 else
%                     cX = obj.getObservations([], featureIndices);
%                 end
%                 
%                 
%                 cEdgeColor = min(classColors(i,:) + 0.2,[0.8 0.8 0.8]);
%                 
%                 switch nPlotDimensions
%                     case 1
%                         handleArray(i) = plot(cX,ones(size(cX)),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
%                         xlabel(getFeatureNames(obj,featureIndices(1)));
%                         grid on
%                     case 2
%                         handleArray(i) = plot(cX(:,1),cX(:,2),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
%                         xlabel(getFeatureNames(obj,featureIndices(1)));
%                         ylabel(getFeatureNames(obj,featureIndices(2)));
%                         grid on
%                     case 3
%                         handleArray(i) = plot3(cX(:,1),cX(:,2),cX(:,3),classSymbols(i),'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',cEdgeColor,'linewidth',0.1);
%                         xlabel(getFeatureNames(obj,featureIndices(1)));
%                         ylabel(getFeatureNames(obj,featureIndices(2)));
%                         zlabel(getFeatureNames(obj,featureIndices(3)));
%                         grid on;
%                 end
%                 if i == 1
%                     hold on;
%                 end
%             end
%             
%             % Set title
%             title(obj.name);
%             
%             % Set hold state back to the way it was
%             if holdState
%                 hold on;
%             else
%                 hold off;
%             end
%             
%             % Create legend
%             if isLabeled
%                 legendStrings = getUniqueTargetNames(obj);
%                 legend(handleArray,legendStrings,'Location','SouthEast');
%             end
%             
%             % Handle Outputs
%             varargout = {};
%             if nargout > 0
%                 varargout = {handleArray,legendStrings};
%             end
%         end
               
    end
        
end