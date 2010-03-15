%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef prtAction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess=private,Abstract) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        name
        nameAbbreviation
        isSupervised
    end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties (SetAccess = protected)
        isTrained = false;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        verboseStorage = true;
        DataSetSummary = [];
        DataSet = [];
        UserData = [];
    end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Abstract) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Obj = trainAction(Obj, DataSet)
        DataSet = runAction(Obj, DataSet)
    end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        function Obj = train(Obj, DataSet)
            Obj = preTrainProcessing(Obj,DataSet);
            Obj = trainAction(Obj, DataSet);
        end
        
        function DataSet = run(Obj, DataSet)
            DataSet = runAction(Obj, DataSet);
            DataSet = postRunProcessing(Obj, DataSet);
        end
        
        function ClassObj = preTrainProcessing(ClassObj,DataSet)
            ClassObj.isTrained = true;
            
            ClassObj.DataSetSummary = summarize(DataSet);
            
            if ClassObj.verboseStorage
                ClassObj.DataSet = DataSet;
            end
        end
        
        function DataSet = postRunProcessing(ClassObj, DataSet)
            % Nothing here.
            % prtClass overloads this for twoClassParadigm
            % Other subclasses may want to also.
        end
        
        function [OutputDataSet, TrainedActions] = crossValidate(Obj, DataSet, validationKeys)
            
            if length(validationKeys) ~= DataSet.nObservations;
                error('Number of validation keys (%d) must match number of data points (%d)',length(validationKeys),PrtDataSet.nObservations);
            end
            
            uKeys = unique(validationKeys);
            
            for uInd = 1:length(uKeys);
                
                %get the testing indices:
                if isa(uKeys(uInd),'cell')
                    cTestLogical = strcmp(uKeys(uInd),validationKeys);
                else
                    cTestLogical = uKeys(uInd) == validationKeys;
                end
                
                testDataSet = DataSet.retainObservations(cTestLogical);
                if length(uKeys) == 1  %1-fold, incestuous train and test
                    trainDataSet = testDataSet;
                else
                    trainDataSet = DataSet.removeObservations(cTestLogical);
                end
                
                classOut = Obj.train(trainDataSet);
                currResults = classOut.run(testDataSet);
                
                if uInd == 1
                    OutputDataSet = prtDataSetUnLabeled(nan(DataSet.nObservations,currResults.nFeatures));
                end
                OutputDataSet = OutputDataSet.setObservations(currResults.getObservations(), cTestLogical);
                
                %only do this if the output is requested; otherwise this cell of
                %classifiers can get very large, and slow things down.
                if nargout >= 2
                    if uInd == 1
                        % First iteration pre-allocate
                        TrainedActions = repmat(classOut,length(uKeys),1);
                    else
                        TrainedActions(uInd) = classOut;
                    end
                end
            end
        end
        function varargout = kfolds(Obj,DataSet,K)
            %[OutputDataSet, ClassStructs, crossValKeys] = kfolds(ActionObj, DataSet, K)
            
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
    
end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%