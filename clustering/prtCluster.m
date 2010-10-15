classdef prtCluster < prtAction
    %prtCluster < prtAction
    % xxx NEED HELP xxx

    properties (SetAccess=private)
        isNativeMary = true; % Logical, classifier natively produces an output for each unique class
    end
    properties (Abstract)
        nClusters
    end
    properties
        internalDecider = [];
    end
    properties (Dependent)
        includesDecision
    end
    properties (SetAccess=protected, Hidden = true)
        yieldsMaryOutput = true; %Clustering algorithms *must*
        twoClassParadigm = 'm-ary';   %  Whether the classifier is binary or m-ary
    end

    properties (Hidden = true)
        PlotOptions = prtClass.initializePlotOptions();  %
    end

    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames) %#ok<MANU>
            if ~obj.includesDecision
                for i = 1:length(featureNames)
                    featureNames{i} = sprintf('%s Membership in cluster %d',obj.nameAbbreviation,i);
                end
            else
                featureNames{1} = 'Class label';
            end
        end
    end

    methods
        function obj = set.internalDecider(obj,val)
            if ~isempty(val) && ~isa(val,'prtDecision')
                error('prtClass:internalDecider','internalDecider must be an empty vector ([]) of type prtDecision, but input is a %s',class(val));
            end
            obj.internalDecider = val;
        end
        function has = get.includesDecision(obj)
            has = ~isempty(obj.internalDecider);
        end
        
        function varargout = plot(Obj)
            % PLOT  Plot the output confidence of a prtClass object
            %
            %   OBJ.plot() plots the output confidence of a prtClass
            %   object. This function only operates when the dimensionality
            %   of dataset is 3 or less. When verboseStorage is set to
            %   'true', the training data points are also displayed on the
            %   plot.
            %
            %   See also: prtClass\plotDecision
            
            assert(Obj.isTrained,'Clusterer must be trained before it can be plotted.');
            assert(Obj.DataSetSummary.nFeatures < 4, 'nFeatures in the training dataset must be less than or equal to 3');
            
            if Obj.yieldsMaryOutput
                % Must produce mary plot
                HandleStructure = plotMaryClusterConfidence(Obj);
            else
                % Single binary plot
                HandleStructure = plotBinaryClusterConfidence(Obj);
            end
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
    end

    methods (Access = protected, Hidden = true)

        function Obj = postTrainProcessing(Obj,DataSet)
             if ~isempty(Obj.internalDecider)
                tempObj = Obj;
                tempObj.internalDecider = [];
                yOut = tempObj.run(DataSet);
                Obj.internalDecider = Obj.internalDecider.train(yOut);
                Obj.internalDecider.classList = 1:Obj.nClusters;
            end
        end

        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(isa(DataSet,'prtDataSetBase'),'DataSet must be a prtDataSetBase DataSet');

            ClassObj.yieldsMaryOutput = ~ClassObj.includesDecision; %determineMaryOutput(ClassObj,DataSet);

            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end

        function OutputDataSet = postRunProcessing(ClassObj, InputDataSet, OutputDataSet)
            % Overload postRunProcessing (from prtAction) so that we can
            % enforce twoClassParadigm
            
            if ~isempty(ClassObj.internalDecider)
                OutputDataSet = ClassObj.internalDecider.run(OutputDataSet);
            end
            
            OutputDataSet = postRunProcessing@prtAction(ClassObj, InputDataSet, OutputDataSet);
        end
        
        % Plotting functions
        function [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj, upperBounds, lowerBounds)

            if nargin < 3 || isempty(lowerBounds)
                lowerBounds = Obj.DataSetSummary.lowerBounds;
            end

            if nargin < 2 || isempty(upperBounds)
                upperBounds = Obj.DataSetSummary.upperBounds;
            end

            [linGrid, gridSize] = prtPlotUtilGenerateGrid(upperBounds, lowerBounds, Obj.PlotOptions.nSamplesPerDim);

            OutputDataSet = run(Obj,prtDataSetClass(linGrid));
        end

        
        function HandleStructure = plotBinaryClusterConfidence(Obj)
            
            [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj);
            %added this hack to make M-ary classifiers *with
            %internalDeciders* output the right colors:
            if Obj.nClusters > 2
                imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(), linGrid, gridSize, Obj.PlotOptions.colorsFunction(Obj.nClusters));
            else
                imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(), linGrid, gridSize, Obj.PlotOptions.twoClassColorMapFunction());
            end
            
            if ~isempty(Obj.DataSet)
                hold on;
                [handles,legendStrings] = plot(Obj.DataSet);
                hold off;
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{handles},'legendStrings',{legendStrings});
            else
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{[]},'legendStrings',{[]});
            end
        end

        function HandleStructure = plotMaryClusterConfidence(Obj)

            [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj);

            % Mary plotting generates a series of subplots that show the
            % confidence of each individual class.

            [M,N] = prtUtilGetSubplotDimensions(Obj.nClusters);
            imageHandle = zeros(M*N,1);

            % The confidences are displayed with class specific color maps
            % These will be lightened up to have contrast with the points
            classColors = prtPlotUtilLightenColors(Obj.PlotOptions.colorsFunction(OutputDataSet.nFeatures));

            nColorMapSamples = 256;

            for subImage = 1:M*N
                cMap = prtPlotUtilLinspaceColormap([1 1 1], classColors(subImage,:),nColorMapSamples);

                cAxes = subplot(M,N,subImage);
                imageHandle(subImage) = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(:,subImage), linGrid, gridSize, cMap);

                prtPlotUtilFreezeColors(cAxes);
            end

            if ~isempty(Obj.DataSet)
                for subImage = 1:M*N
                    subplot(M,N,subImage)
                    hold on;
                    [handles,legendStrings] = plot(Obj.DataSet);
                    hold off;
                    HandleStructure.Axes(subImage) = struct('imageHandle',{imageHandle(subImage)},'handles',{handles},'legendStrings',{legendStrings});
                end
            else
                for subImage = 1:M*N
                    HandleStructure.Axes(subImage) = struct('imageHandle',{imageHandle(subImage)},'handles',{[]},'legendStrings',{[]});
                end
            end
        end
        
    end

    methods (Static, Hidden = true)
        function PlotOptions =initializePlotOptions()
            UserOptions = prtUserOptions;
            PlotOptions = UserOptions.ClassifierPlotOptions;
        end
    end
end