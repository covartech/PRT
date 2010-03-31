classdef prtAction
    % prtAction Properties:
    %   name - (Abstract) Char, Descriptive name
    %   nameAbbreviation - (Abstract) Char, Shortened (2-4 character) name 
    %   isSupervised - (Abstract) Logical, Requires classifier training
    %   isTrained - (Read only) Logical, current status of the object
    %   verboseStorage - Logical, store dataset with action object
    %   DataSetSummary - Struct, output of summarize(DataSet)
    %   DataSet - prtDataSet, only non-empty if verboseStorage == true
    %   UserData - Struct, user specified data
    %
    % prtAction Methods:
    %   trainAction - (Abstract) Primary method for training a prtAction
    %   runAction - (Abstract) Primary method for running a prtAction
    %   train - Train action object using prtDataSet
    %   run - Run action object on prtDataSet
    %   crossValidate - Cross-validate action object using dataSet and keys
    %   preTrainProcessing - (Protected) Called by train() prior to trainAction()
    %   postRunProcessing - (Protected) Called by run() after runAction()
    
    properties (Abstract, SetAccess = private)
        name % Char, Descriptive name
        nameAbbreviation % Char, Shortened (2-4 character) name 
        isSupervised % Logical, requires training data to run
    end
    
    properties (SetAccess = protected)
        isTrained = false; % Logical, has been properly trained
    end
    
    properties
        verboseStorage = true; % Logical, specifies to store training dataSet with object
        DataSetSummary = []; % Struct, Output of summarize(DataSet)
        DataSet = []; % prtDataSet, only stored if verboseStorage == true
        UserData = []; % Struct, user specified data
    end
    
    methods (Abstract)
        Obj = trainAction(Obj, DataSet)
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
            ClassObj.isTrained = true;
            ClassObj.DataSetSummary = summarize(DataSet);
            if ClassObj.verboseStorage
                ClassObj.DataSet = DataSet;
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