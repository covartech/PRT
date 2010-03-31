classdef prtAction
    % prtAction - Base class for PRT pattern classificaiton components.
    %   Classification techniques, Regression techniques, Feature selection
    %   techniques, etc. Are all sub-classes of prtAction.
    %
    % prtAction Properties:
    %   name - (Abstract) Descriptive name for prtAction
    %   nameAbbreviation - (Abstract) Shortened name for prtAction name
    %   isSupervised - (Abstract) Logical, Requires classifier training
    %   isTrained - (Read only) Logical, current status of the object
    %   verboseStorage - (Logical, store dataset with action object
    %   DataSetSummary - Struct, output of summarize(DataSet)
    %   DataSet - prtDataSet, only non-empty if verboseStorage == true
    %   UserData - Struct, user specified data
    %
    % prtAction Methods:
    %   train - Train prtAction using prtDataSet
    %   run - Evaluate prtAction on prtDataSet
    %   crossValidate - Cross-validate prtAction using prtDataSet and keys
    %   kfolds - K-folds cross-validate a prtAction using prtDataSet
    %   trainAction - (Abstract) Primary method for training a prtAction
    %   runAction - (Abstract) Primary method for running a prtAction
    %   preTrainProcessing - (Protected) Called by train() prior to trainAction()
    %   postRunProcessing - (Protected) Called by run() after runAction()
    %
    % See Also: prtClass, prtRegress, prtFeatSel, prtPreProc, prtDataSet
    
    properties (Abstract, SetAccess = private)
        % prtAction.name - Descriptive name of classifier object.
        name 
        
        % prtAction.nameAbbreviation - Shortened name for the prtAction.
        nameAbbreviation 
        
        % prtAction.isSupervised - Specifies if prtAction requires
        % training.
        isSupervised % Logical, requires training data to run
    end
    
    properties (SetAccess = protected)
        % prtAction.isTrained - Specifies if prtAction has been trained.
        %   Set automatically in prtAction.train().
        isTrained = false;
        
        % prtAction.DataSetSummary - Structure that summarizes prtDataSet.
        %   Produced by prtDataSet.summarize() and stored in
        %   prtAction.train(). Used to characterize the dataset for
        %   plotting when prtAction.verboseStorage == false
        DataSetSummary = [];
        
        % prtAction.DataSet - Training prtDataSet. 
        %   Only stored if prtAction.verboseStorage == true. Otherwise it
        %   is empty.
        DataSet = []; 
    end
    
    properties
        % prtAction.verboseStorage - Specifies storage the training prtDataset.
        % If true the prtDataSet is stored internally in prtAction.DataSet.
        verboseStorage = true;
        
        % prtAction.UserData - User specified data. 
        %   Some prtActions store additional information from
        %   prtAction.run() as a structure in prtAction.UserData()
        UserData = [];
    end
    
    methods (Abstract, Access = protected)
        % prtAction.trainAction() - Primary method for training a prtAction
        %   Obj = prtAction.trainAction(Obj,DataSet)
        Obj = trainAction(Obj, DataSet)
        
        % prtAction.runAction() - Primary method for evaluating a prtAction
        %   DataSet = runAction(Obj, DataSet)
        DataSet = runAction(Obj, DataSet)
    end
    
    methods
        function Obj = train(Obj, DataSet)
            % train - Train prtAction using training a prtDataSet
            %   Obj = train(Obj, DataSet)
            %
            % Obj.train() first calls Obj.preTrainProcessing() and then
            % calls Obj.trainAction()
            
            % Default preTrainProcessing() stuff
            Obj.isTrained = true;
            Obj.DataSetSummary = summarize(DataSet);
            if Obj.verboseStorage
                Obj.DataSet = DataSet;
            end
            
            Obj = preTrainProcessing(Obj,DataSet);
            Obj = trainAction(Obj, DataSet);
        end
        
        function DataSet = run(Obj, DataSet)
            % run - Run a trained prtAction on test prtDataSet, DataSet
            %   DataSet = run(Obj, DataSet)
            %
            % Obj.run() first calls Obj.runAction() and then calls
            % Obj.postRunProcessing()
            
            DataSet = runAction(Obj, DataSet);
            DataSet = postRunProcessing(Obj, DataSet);
        end
        
        function [OutputDataSet, TrainedActions] = crossValidate(Obj, DataSet, validationKeys)
            % crossValidate - Cross-Validate prtAction using prtDataSet
            %   and specified cross-validation keys. If the second output
            %   is requested each of the trained prtActions is returned.
            %   This will have a length equal to the number of unique
            %   validation keys.
            %
            % [OutputDataSet, TrainedActions] = crossValidate(Obj, DataSet, validationKeys)
            
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
    
    methods (Access=protected)
        function ClassObj = preTrainProcessing(ClassObj,DataSet)
            % preTrainProcessing - Processing done prior to train()
            %   Called by train(). Can be overloaded by prtActions to
            %   store specific information about the DataSet or Classifier
            %   prior to training.
            %
            %   ClassObj = preTrainProcessing(ClassObj,DataSet)
        end
        
        function DataSet = postRunProcessing(ClassObj, DataSet)
            % postRunProcessing - Processing done after run()
            %   Called by run(). Can be overloaded by prtActions to alter
            %   the results of run() to modify outputs using parameters of
            %   the prtAction.
            %
            %   DataSet = postRunProcessing(ClassObj, DataSet)
        end
    end
end