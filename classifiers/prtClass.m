classdef prtClass < prtAction
    % prtClass   Base class for prt Classification objects
    %
    % All prtClass objects inherit all properities and methods from the
    % prtActoin object. prtClass objects have the following additional
    % properties:
    % 
    %   isNativeMary - Whather or not the classifier natively produces an
    %                  M-ary result.
    %
    %   internalDecider - (Optional, default = []) an instance of a
    %                   prtDecision object.  When set, the classifier will
    %                   output discrete values corresponding to the class
    %                   determined by the classifier and the decision
    %                   object (binary classifier), or a binary vector of
    %                   zeros and ones (M-ary classification)
    %
    %   prtClass objects have the following methods:
    %
    %   plot          - Plot the output confidence of a trained classifier
    %                   (classifiers trained with ds with <= 3 features only)
    %
    %   Inherited from prtAction:
    % 
    %   train         - Train the classifier using a prtDataSetClass and
    %                   output a trained classifier, e.g.
    %       myClassifier = myClassifier.train(ds);
    %
    %   run           - Run the classifier on a data set, e.g.
    %       results = myClassifier.run(ds);
    %
    %
    %   crossValidate, kfolds - See prtAction
    %
    %
    %   Sub-classing prtClass:
    %       Concrete sub-classes of prtClass must define the abstract
    %   methods trainAction and runAction defined in prtAction.  These
    %   methods have function definitions as follows:
    %
    %       Obj = trainAction(Obj, DataSet)
    %       DataSet = runAction(Obj, DataSet)
    %
    %   Both methods are protected and hidden.  A concrete subclass of
    %   prtClass should contain code similar to the following:
    %
    %
    %     methods (Access = protected, Hidden = true)
    %         function Obj = trainAction(Obj, DataSet)
    %           %Code to set trained parameters of Obj
    %           
    %         end
    %
    %         function DataSetOut = runAction(Obj, DataSet)
    %           %Code to run trained Obj on DataSet and generate DataSetOut
    %           %with observations set to the output of the classification
    %           %algorithm
    %
    %         end
    %     end
    %
    %
    
    properties (SetAccess=private, Abstract)
        isNativeMary % Logical, classifier natively produces an output for each unique class
    end
    
    properties (SetAccess=private)
        isSupervised = true;
    end
    properties
        twoClassParadigm = 'binary';   %  Whether the classifier is binary or m-ary
    end
    properties (SetAccess=protected, Hidden = true)
        yieldsMaryOutput = nan; % Determined in trainProcessing()
    end
    properties
        internalDecider = [];
    end
    properties (Dependent = true)
        includesDecision
    end
    properties (Hidden = true)
        PlotOptions = prtClass.initializePlotOptions();
    end
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames)
            if ~obj.includesDecision
                for i = 1:length(featureNames)
                    featureNames{i} = sprintf('%s Output_{%d}',obj.nameAbbreviation,i);
                end
            else
                featureNames{1} = 'Class Label';
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
            
            assert(Obj.isTrained,'Classifier must be trained before it can be plotted.');
            assert(Obj.DataSetSummary.nFeatures < 4, 'nFeatures in the training dataset must be less than or equal to 3');
            
            if Obj.yieldsMaryOutput
                % Must produce mary plot
                HandleStructure = plotMaryClassifierConfidence(Obj);
            else
                % Single binary plot
                HandleStructure = plotBinaryClassifierConfidence(Obj);
            end
            
            if ~isempty(Obj.DataSet) && ~isempty(Obj.DataSet.name)
                title(sprintf('%s (%s)',Obj.name,Obj.DataSet.name));
            else
                title(Obj.name);
            end
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        
        function Obj = set.twoClassParadigm(Obj,val)
            assert(ischar(val),'twoClassParadigm must be a string that is ''binary'' or ''mary''');
            assert(ismember(lower(val),{'binary','mary','m-ary'}),'twoClassParadigm must be either ''binary'' or ''mary');
            Obj.twoClassParadigm = lower(val);
        end
    end

    methods (Hidden = true)
        function explore(Obj)
            % explore() Explore the decision contours of classifiers
            % operating on high dimensional data.
            %   
            % ds = prtDataGenIris; t = train(prtClassMAP('internalDecider',prtDecisionMap),ds); explore(t)
            
            assert(~isempty(Obj.isTrained),'explore() is only for trained classifiers.');
            assert(~isempty(Obj.DataSet),'explore() requires that verboseStorage is true and therefore a prtDataSet is stored within the classifier.');
            assert(~Obj.yieldsMaryOutput,'explore() is only for binary classifiers or classifiers that have an internal decider.');
            
            prtPlotUtilClassExploreGui(Obj)
        end
        
        function varargout = plotBinaryConfidenceWithFixedFeatures(Obj,freeDims,featureValues)
            
            assert(Obj.isTrained,'plotWithFixedFeatures requires a trained classifier.');
            assert(~Obj.yieldsMaryOutput,'plotWithFixedFeatures is currently only for classifiers that return a single decision statistic');
            assert(numel(freeDims)==2 || numel(freeDims)==3,'Two or three freeDims must be specified.')
            
            if length(featureValues) == Obj.DataSetSummary.nFeatures
                featureValues = featureValues(setdiff(1:Obj.DataSetSummary.nFeatures,freeDims));
            else
                assert(numel(featureValues) == (Obj.DataSetSummary.nFeatures-length(freeDims)),'Invalid feature values specified.');
            end
            
            [linGrid,gridSize] = prtPlotUtilGenerateGrid(Obj.DataSetSummary.lowerBounds(freeDims), Obj.DataSetSummary.upperBounds(freeDims), Obj.PlotOptions.nSamplesPerDim);
            
            XLinGrid = nan(size(linGrid,1), Obj.DataSetSummary.nFeatures);
            XLinGrid(:,freeDims) = linGrid;
            XLinGrid(:,setdiff(1:Obj.DataSetSummary.nFeatures,freeDims)) = repmat(featureValues(:)',size(linGrid,1),1);
            
            OutputDataSet = run(Obj,prtDataSetClass(XLinGrid));
            
            if Obj.DataSetSummary.nClasses > 2
                %internalDeciders output the right colors:
                imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(), linGrid, gridSize, prtPlotUtilLightenColors(Obj.PlotOptions.colorsFunction(Obj.DataSetSummary.nClasses)));
            else
                imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(), linGrid, gridSize, Obj.PlotOptions.twoClassColorMapFunction());
            end
            
            HandleStructure.imageHandle = imageHandle;
            
            if ~isempty(Obj.DataSet) && ~isempty(Obj.DataSet.name)
                title(sprintf('%s (%s)',Obj.name,Obj.DataSet.name));
            else
                title(Obj.name);
            end
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        
        function produceMaryOutput = determineMaryOutput(ClassObj,DataSet)
            % Determine if an Mary output will be provided by the classifier
            % Determined by the dataSet the classifier capabilities and the            
            % twoClassParadigm switch
            if nargin ~= 2 || ~isa(DataSet,'prtDataSetBase')
                error('prt:prtClass:determineMaryOutput:invalidInput','Invalid input.');
            end
            produceMaryOutput = false; % Default answer only do mary in special conditions
            
            if DataSet.isMary
                % You have Mary data so you want an Mary output
                if ClassObj.isNativeMary
                    % You have Mary data and an Mary Classifier
                    % so you want an Mary output
                    produceMaryOutput = true;
                else
                    % Binary only classifier with Mary Data
                    error('prt:prtClass:classifierDataSetMismatch','M-ary classification is not supported by this classifier. You will need to use prtClassBinaryToMaryOneVsAll() or an equivalent M-ary emulation classifier.');
                end
            elseif DataSet.isBinary && ClassObj.isNativeMary
                % You have binary data and an Mary Classifier
                % We must check twoClassParadigm to see what you want
                produceMaryOutput = ~strcmpi(ClassObj.twoClassParadigm, 'binary');
            end % Unary Data -> false
            
            if ClassObj.includesDecision
                produceMaryOutput = false;
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
            end
        end
        
        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(isa(DataSet,'prtDataSetBase'),'DataSet must be a prtDataSetBase DataSet');
            
            ClassObj.yieldsMaryOutput = determineMaryOutput(ClassObj,DataSet);
            
            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end
        
        function OutputDataSet = postRunProcessing(ClassObj, InputDataSet, OutputDataSet)
            % Overload postRunProcessing (from prtAction) so that we can
            % enforce twoClassParadigm
            
            if ~isempty(ClassObj.internalDecider)
                OutputDataSet = ClassObj.internalDecider.run(OutputDataSet);
            end
            
            if ~isempty(ClassObj.yieldsMaryOutput) && ~isnan(ClassObj.yieldsMaryOutput)
                if ClassObj.yieldsMaryOutput
                    % Mary classifier output mary decision statistics
                    % enforce that it has output one for each class in the
                    % training data set.
                    assert(OutputDataSet.nFeatures == ClassObj.DataSetSummary.nClasses,'M-ary classifiers must yield observations with nFeatures equal to the number of unique classes in the training data set. This classifier must be modified to output observations with the proper dimensionality. If integer outputs are desired, output a binary matrix.');
                else
                    % Run Function provided mary output but ClassObj knows
                    % not to supply this. We must run
                    % maryOutput2binaryOutput()
                    OutputDataSet = maryOutput2binaryOutput(ClassObj,OutputDataSet);
                end
            end
            
            OutputDataSet = postRunProcessing@prtAction(ClassObj, InputDataSet, OutputDataSet);
        end
        
        function OutputDataSet = maryOutput2binaryOutput(ClassObj,OutputDataSet) %#ok
            % Default method to convert an Mary output to a Binary output 
            % Can/should be overloaded by classifiers
            
            % The default just takes the last (right-most) output dimension
            % In classifiers this will typically be the confidence of the
            % class with the highest valued target index.
            OutputDataSet = OutputDataSet.setObservations(OutputDataSet.getObservations(:,end));
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
        
        function HandleStructure = plotBinaryClassifierConfidence(Obj)
            
            [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj);
            
            if Obj.DataSetSummary.nClasses > 2
                %internalDeciders* output the right colors:
                imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(), linGrid, gridSize, prtPlotUtilLightenColors(Obj.PlotOptions.colorsFunction(Obj.DataSetSummary.nClasses)));
            else
                imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(OutputDataSet.getObservations(), linGrid, gridSize, Obj.PlotOptions.twoClassColorMapFunction());
            end
            
            if ~isempty(Obj.DataSet)
                hold on;
                handles = plot(Obj.DataSet);
                hold off;
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{handles});
            else
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{[]});
            end
        end
        
        function HandleStructure = plotMaryClassifierConfidence(Obj)
            
            [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj);
            
            % Mary plotting generates a series of subplots that show the
            % confidence of each individual class.
            
            [M,N] = prtUtilGetSubplotDimensions(Obj.DataSetSummary.nClasses);
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
            PlotOptions = prtOptionsGet('prtOptionsClassPlot');
        end
    end
end