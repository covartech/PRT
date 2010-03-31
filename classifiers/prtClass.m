%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef prtClass < prtAction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prtClass Properties:
    %   isNativeMary - Logical, classifier natively produces an output for each unique class
    %   
    % prtClass Methods:
    %   kfolds - generate kfolds cross-val keys and cross val action
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess=private, Abstract) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        isNativeMary
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess=protected) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        yieldsMaryOutput = nan; % Determined in trainProcessing()
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PlotOptions = prtClassPlotOpt;
        twoClassParadigm = 'binary';
    end 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj, upperBounds, lowerBounds)
            
            if nargin < 3 || isempty(lowerBounds)
                lowerBounds = Obj.DataSetSummary.lowerBounds;
            end
            
            if nargin < 2 || isempty(upperBounds)
                upperBounds = Obj.DataSetSummary.upperBounds;
            end
            
            [linGrid, gridSize] = prtPlotUtilGenerateGrid(upperBounds, lowerBounds, Obj.PlotOptions);

            OutputDataSet = run(Obj,prtDataSet(linGrid));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function HandleStructure = plotBinaryClassifierConfidence(Obj)
            
            [OutputDataSet, linGrid, gridSize] = runClassifierOnGrid(Obj);
            % Map through PlotOptions.mappingFunction (ex. log)
            if ~isempty(Obj.PlotOptions.mappingFunction)
                OutputDataSet = OutputDataSet.setObservations(feval(OutputDataSet.PlotOptions.mappingFunction, OutputDataSet.getObservations()));
            end
            
            imageHandle = plotGriddedEvaledClassifier(Obj, reshape(OutputDataSet.getObservations(),gridSize), linGrid, gridSize, Obj.PlotOptions.twoClassColorMapFunction());
            
            if ~isempty(Obj.DataSet)
                hold on;
                [handles,legendStrings] = plot(Obj.DataSet);
                hold off;
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{handles},'legendStrings',{legendStrings});
            else
                HandleStructure.Axes = struct('imageHandle',{imageHandle},'handles',{[]},'legendStrings',{[]});
            end            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function HandleStructure = plotMaryClassifierConfidence(Obj) %%%%%%
            
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
                imageHandle(subImage) = plotGriddedEvaledClassifier(Obj, reshape(OutputDataSet.getObservations(:,subImage),gridSize), linGrid, gridSize, cMap);
                
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function imageHandle = plotGriddedEvaledClassifier(Obj, DS, linGrid, gridSize, cMap)
            nDims = size(linGrid,2);
            switch nDims
                case 1
                    imageHandle = imagesc(linGrid(:,1),linGrid(:,2),DS);
                    set(gca,'YTickLabel',[])
                    colormap(cMap)
                case 2
                    xx = reshape(linGrid(:,1),gridSize);
                    yy = reshape(linGrid(:,2),gridSize);
                    imageHandle = imagesc(xx(1,:),yy(:,1),DS);
                    colormap(cMap)
                case 3
                    xx = reshape(linGrid(:,1),gridSize);
                    yy = reshape(linGrid(:,2),gridSize);
                    zz = reshape(linGrid(:,3),gridSize);
                    imageHandle = slice(xx,yy,zz,DS,max(xx(:)),max(yy(:)),[min(zz(:)),mean(zz(:))]);
                    view(3)
                    colormap(cMap)
                    imageHandle = imageHandle(1); % Sorry we need to throw the others away
            end
            axis tight;
            axis xy;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function varargout = plot(Obj) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function varargout = plotDecision(Obj) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

            imageHandle = plotGriddedEvaledClassifier(Obj, reshape(OutputDataSet.getObservations(),gridSize), linGrid, gridSize, cMap);
            
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
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Determine if an Mary output will be provided by the classifier %%
        % Determined by the dataSet the classifier capabilities and the %%%
        % twoClassParadigm switch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function produceMaryOutput = determineMaryOutput(ClassObj,DataSet)
            if nargin ~= 2 || ~isa(DataSet,'prtDataSetBase')
                error('prt:prtClass:determineMaryOutput:invalidInput','Invalid input.');
            end
            produceMaryOutput = false; % Default answer only do mary in special conditions
            if isa(DataSet, 'prtDataSetBaseClass')
                % You provided some form of Class DataSet which means you
                % have dependent properties "isBinary", "isMary"
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
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Overload preTrainProcessing() so that we can determine mary %%%%%
        % output status %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ClassObj = preTrainProcessing(ClassObj, DataSet) %%%%%%%%%
            assert(isa(DataSet,'prtDataSetBaseClass'),'DataSet must be a prtClass DataSet');
            
            ClassObj.yieldsMaryOutput = determineMaryOutput(ClassObj,DataSet);
            
            ClassObj = preTrainProcessing@prtAction(ClassObj,DataSet);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Overload postRunProcessing (from prtAction) so that we can %%%%%%
        % enforce twoClassParadigm %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function OutputDataSet = postRunProcessing(ClassObj, OutputDataSet)
            if (OutputDataSet.nFeatures~=1) && ~ClassObj.yieldsMaryOutput
                % Run Function provided mary output but ClassObj knows not
                % to supply this. We must run maryOutput2binaryOutput()
                OutputDataSet = maryOutput2binaryOutput(ClassObj,OutputDataSet);
            end
            OutputDataSet = postRunProcessing@prtAction(ClassObj, OutputDataSet);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Default method to convert an Mary output to a Binary output %%%%%
        % Can/should be overloaded by classifiers %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function OutputDataSet = maryOutput2binaryOutput(ClassObj,OutputDataSet) %#ok
            OutputDataSet = OutputDataSet.setObservations(OutputDataSet.getObservations(:,end));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function varargout = kfolds(Obj,DataSet,K)
            % kfolds - Perform k-folds cross validation of prtAction 
            %   on a prtDataSet. Generates cross validation keys by
            %   patitioning the dataSet into K groups such that the number
            %   of samples of each uniqut target type is attempted to be
            %   held constant.
            %
            % [OutputDataSet, TrainedActions, crossValKeys] = kfolds(ActionObj, DataSet, K)
            
            if nargin == 2 || isempty(K)
                K = DataSet.nObservations;
            end
            
            nObs = DataSet.nObservations;
            if K > nObs;
                warning('prt:prtAction:kfolds:nFolds','Number of folds (%d) is greater than number of data points (%d); assuming Leave One Out training and testing',K,nObs);
                K = nObs;
            elseif K < 1
                warning('prt:prtAction:kfolds:nFolds','Number of folds (%d) is less than 1 assuming FULL training and testing',K);
                K = 1;
            end
            
            keys = prtUtilEquallySubDivideData(DataSet.getTargets(),K);
            
            outputs = cell(1,min(max(nargout,1),2));
            [outputs{:}] = Obj.crossValidate(DataSet,keys);
            
            varargout = outputs(:);
            if nargout > 2
                varargout = [varargout; {keys}];
            end
                
        end
        
    end 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%