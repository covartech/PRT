classdef prtOutlierRemoval < prtAction
    % prtOutlierRemoval Base class for prt Outlier Removal objects
    %
    % All prtOutlierRemoval objects inherit all properities and methods
    % from the prtActoin object. prtOutlierRemoval objects have the
    % following additional properties:
    %
    %   runMode and runOnTrainingMode - These string valued properties
    %   specify how the outlier removal processing behaves when run on a
    %   data set.  runMode specifies how the action behaves during typical
    %   calls to "run".  runOnTrainingMode specifies how the action should
    %   behave when the outlier removal object is embedded in a
    %   prtAlgorithm.  The distinction between runOnTrainingMode and
    %   runMode enables outlier removal during training to modify how
    %   prtActions down-stream of the outlier removal object are trained,
    %   while maintaining valid cross-validation folds during "run".
    %
    %   runMode - A string specifying how the outlier removal method should
    %   behave during running.  Default value is 'noAction'. Valid strings
    %   and descriptions follow:
    %
    %       'noAction' - When running the outlier removal action, do
    %       nothing.  This ensures that the outlier removal action outputs
    %       data sets of the same size as the input data set.
    %
    %       'replaceWithNan' - When running the outlier removal action
    %       replace outlier values with nans.  This ensures that the
    %       outlier removal action outputs data sets of the same size as
    %       the input data set.
    %
    %       'removeObservation' - When running the outlier removal action,
    %       remove observations where any feature value is flagged as an
    %       outlier.  This can change the size of the data set during
    %       running and can result in invalid cross-validation folds.
    %
    %       'removeFeature'  - When running the outlier removal action,
    %       remove features where any observation contains an outlier.
    %       
    %   runOnTrainingMode - A string specifying how the outlier removal
    %   method should behave when being run during the training of a
    %   prtAlgorithm.  See above for a more detailed description, and a
    %   list of valid runOnTrainingMode string values.  Default value is
    %   'removeObservation'.
    % 
    %   prtClass objects have the following Abstract methods:
    %
    %   calculateOutlierIndices - An abstract method that concrete
    %   sub-classes must define.  calculateOutlierIndices takes the form:
    %
    %       indices = calculateOutlierIndices(Obj,DataSet)
    %
    %   where indices is a logical matrix of size DataSet.nObservations x
    %   DataSet.nFeatures.  The (i,j) element of indices specifies whether
    %   that element of DataSet is an outlier.
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
    %   crossValidate, kfolds - See prtAction
    %
    %  To define a new outlier removal algorithm...
    %
    %    You: need to overload trainAction and calculateOutlierIndices...
    % then set trainingMode and testingMode to do whatever you wants.
    %
    % Note; do not overload any testing stuff!
    
    methods (Abstract, Access = protected, Hidden = true)
        indices = calculateOutlierIndices(Obj,DataSet)
    end
    
    properties
        runOnTrainingMode = 'removeObservation';
        runMode = 'noAction';
    end
    properties (Access = 'private')
        validModes = {'noAction','replaceWithNan','removeObservation','removeFeature'};
    end
    
    methods
        
        function Obj = set.runOnTrainingMode(Obj,string)
            if ~any(strcmpi(string,Obj.validModes))
                error('prtOutlierRemoval:runOnTrainingMode','runOnTrainingMode must be one of the follwing strings: {%s}',sprintf('%s ',Obj.validModes{:}));
            end
            Obj.runOnTrainingMode = string;
        end
        
        function Obj = set.runMode(Obj,string)
            if ~any(strcmpi(string,Obj.validModes))
                error('prtOutlierRemoval:runOnTrainingMode','runOnTrainingMode must be one of the follwing strings: {%s}',sprintf('%s ',Obj.validModes{:}));
            end
            Obj.runMode = string;
            if strcmpi(Obj.runMode,'removeObservation')
                Obj.isCrossValidateValid = false;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = outlierRemovalRun(Obj,DataSet,Obj.runMode);
        end
        function DataSet = runActionOnTrainingData(Obj,DataSet)
            DataSet = outlierRemovalRun(Obj,DataSet,Obj.runOnTrainingMode);
        end
        
        function DataSet = outlierRemovalRun(Obj,DataSet,mode)
            switch mode
                case 'noAction'
                    return;
                case 'removeObservation'
                    ind = Obj.calculateOutlierIndices(DataSet);
                    removeInd = any(ind,2);
                    DataSet = DataSet.removeObservations(removeInd);
                case 'removeFeature'
                    ind = Obj.calculateOutlierIndices(DataSet);
                    removeInd = any(ind,1);
                    DataSet = DataSet.removeFeatures(removeInd);
                case 'replaceWithNan'
                    ind = Obj.calculateOutlierIndices(DataSet);
                    x = DataSet.getObservations;
                    x(ind) = nan;
                    DataSet = DataSet.setObservations(x);
                otherwise 
                    error('invalid string');
            end
        end
    end
end