classdef prtClass < prtAction
    % prtClass   Base class for prt Classification objects
    %
    % All prtClass objects inherit all properities and methods from the
    % prtActoin object. prtClass objects have the following additional
    % properties:
    % 
    %   isNativeMary - Whather or not the classifier natively produces an
    %                  M-ary result.
    %   PlotOptions -  prtClassPlotOpt object specifying the plotting
    %                  options
    %   twoClassParadigm - {'Binary','Mary')  XXXX What is this for?
    %
    %   prtClass objects have the following methods:
    %
    %   plot          - Plot the output confidence
    %   plotDecision  - Plot the decision boundaries
    
    properties (SetAccess=private, Abstract)
        isNativeMary % Logical, classifier natively produces an output for each unique class
    end
    
    properties (SetAccess=protected, Hidden = true)
        yieldsMaryOutput = nan; % Determined in trainProcessing()
    end
    
    properties
        PlotOptions = prtClass.initializePlotOptions();
        twoClassParadigm = 'binary';   %  Whether the classifier is binary or m-ary
    end
    
    methods
        
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
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        
        function varargout = plotDecision(Obj)         
            % PLOTDECISION  Plot the decision boundaries of a prtClass object
            % 
            %   OBJ.plotDecision() plots the decision boundaries of a prtClass
            %   object. This function only operates when the dimensionality
            %   of dataset is 3 or less. When verboseStorage is set to
            %   'true', the training data points are also displayed on the
            %   plot. 
            %  
            %   See also: prtClass\plot
            
            assert(Obj.isTrained,'Classifier must be trained before it can be plotted.');
            assert(Obj.DataSetSummary.nFeatures < 4, 'nFeatures in the training dataset must be less than or equal to 3');
            
            [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj);
            
            % Map the output dataset to hard class decisions
            if Obj.yieldsMaryOutput
                [~, classOutInd] = max(OutputDataSet.getObservations(),[],2);
                OutputDataSet = OutputDataSet.setObservations(classOutInd);
            else
                threshold = mean(OutputDataSet.getObservations());
                OutputDataSet = OutputDataSet.setObservations(OutputDataSet.getObservations() > threshold);
            end
            
            cMap = Obj.PlotOptions.colorsFunction(Obj.DataSetSummary.nClasses);
            % Lighten the colors
            cMap = cMap + 0.2;
            cMap(cMap > 1) = 1;
            
            imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(reshape(OutputDataSet.getObservations(),gridSize), linGrid, gridSize, cMap);
            
            if ~isempty(Obj.DataSet)
                hold on;
                [handles,legendStrings] = plot(Obj.DataSet);
                hold off;
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{handles},'legendStrings',{legendStrings});
            else
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{[]},'legendStrings',{[]});
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
    
    methods (Access = protected, Hidden = true)

        function ClassObj = preTrainProcessing(ClassObj, DataSet)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            assert(isa(DataSet,'prtDataSetBase'),'DataSet must be a prtDataSetBase DataSet');
            
            ClassObj.yieldsMaryOutput = determineMaryOutput(ClassObj,DataSet);
            
            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end
        
        function OutputDataSet = postRunProcessing(ClassObj, OutputDataSet)
            % Overload postRunProcessing (from prtAction) so that we can
            % enforce twoClassParadigm
            
            if (OutputDataSet.nFeatures~=1) && ~ClassObj.yieldsMaryOutput
                % Run Function provided mary output but ClassObj knows not
                % to supply this. We must run maryOutput2binaryOutput()
                OutputDataSet = maryOutput2binaryOutput(ClassObj,OutputDataSet);
            end
            OutputDataSet = postRunProcessing@prtAction(ClassObj, OutputDataSet);
        end

        function produceMaryOutput = determineMaryOutput(ClassObj,DataSet)
            % Determine if an Mary output will be provided by the classifier %%
            % Determined by the dataSet the classifier capabilities and the %%%
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
                    error('prt:prtClass:classifierDataSetMismatch','M-ary classification is not supported by this classifier. You will need to use prtClassMaryOneVsAll() or prtClassMaryPairWise()');
                end
            elseif DataSet.isBinary && ClassObj.isNativeMary
                % You have binary data and an Mary Classifier
                % We must check twoClassParadigm to see what you want
                produceMaryOutput = ~strcmpi(ClassObj.twoClassParadigm, 'binary');
            end % Unary Data -> false
        end
                
        function OutputDataSet = maryOutput2binaryOutput(ClassObj,OutputDataSet) %#ok
            % Default method to convert an Mary output to a Binary output %%%%%
            % Can/should be overloaded by classifiers %%%%%%%%%%%%%%%%%%%%%%%%%
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
            % Map through PlotOptions.mappingFunction (ex. log)
            if ~isempty(Obj.PlotOptions.mappingFunction)
                OutputDataSet = OutputDataSet.setObservations(feval(OutputDataSet.PlotOptions.mappingFunction, OutputDataSet.getObservations()));
            end
            
            imageHandle = prtPlotUtilPlotGriddedEvaledClassifier(reshape(OutputDataSet.getObservations(),gridSize), linGrid, gridSize, Obj.PlotOptions.twoClassColorMapFunction());
            
            if ~isempty(Obj.DataSet)
                hold on;
                [handles,legendStrings] = plot(Obj.DataSet);
                hold off;
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{handles},'legendStrings',{legendStrings});
            else
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{[]},'legendStrings',{[]});
            end
        end
        
        function HandleStructure = plotMaryClassifierConfidence(Obj)
            
            [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj);
            % Map through PlotOptions.mappingFunction (ex. log)
            if ~isempty(Obj.PlotOptions.mappingFunction)
                OutputDataSet = OutputDataSet.setObservations(feval(OutputDataSet.PlotOptions.mappingFunction, OutputDataSet.getObservations()));
            end
            
            [M,N] = getSubplotDimensions(Obj.DataSetSummary.nClasses);
            imageHandle = zeros(M*N,1);
            classColors = prtPlotUtilLightenColors(Obj.PlotOptions.colorsFunction(OutputDataSet.nFeatures));
            for subImage = 1:M*N
                cMap = prtPlotUtilLinspaceColormap([1 1 1], classColors(subImage,:),256);
                
                cAxes = subplot(M,N,subImage);
                imageHandle(subImage) = prtPlotUtilPlotGriddedEvaledClassifier(reshape(OutputDataSet.getObservations(:,subImage),gridSize), linGrid, gridSize, cMap);
                
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%