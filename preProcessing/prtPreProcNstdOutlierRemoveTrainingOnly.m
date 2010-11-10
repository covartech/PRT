classdef prtPreProcNstdOutlierRemoveTrainingOnly < prtPreProcNstdOutlierRemove
    % prtPreProcNstdOutlierRemoveTrainingOnly  Removes outliers from a
    %   prtDataSet but only during training of a prtAlgorithm
    %   See prtPreProcNstdOutlierRemove
    %
    %   NSTDOUT = prtPreProcNstdOutlierRemoveTrainingOnly creates a
    %   pre-processing object that removes observations where any of the 
    %   feature values is more then nStd standard deviations from the mean
    %   of that feature.
    % 
    %   prtPreProcNstdOutlierRemoveTrainingOnly has the following properties:
    %
    %       nStd    - The number of standard deviations at which to remove
    %                 an observation (default = 3)
    %
    %   A prtPreProcNstdOutlierRemoveTrainingOnly object also inherits all
    %   properties and functions from the prtAction class.
    %
    %   Example:
    %       dataSetOriginal = prtDataGenUnimodal;
    %       outlier = prtDataSetClass([-10 -10; 20 20;-10 20; 20 -10],[1, 0, 1 ,1]');
    %       dataSet = catObservations(dataSetOriginal,outlier);
    %
    %       classifier = prtClassMap('rvs',prtRvMvn);
    %       algo = prtPreProcNstdOutlierRemoveTrainingOnly('nStd',3) + classifier;
    %
    %       trainedAlgorithmWithoutOutliers = algo.train(dataSet);
    %       trainedClassifierWithOutliers = classifier.train(dataSet);
    %
    %       subplot(2,1,1);
    %       plot(trainedAlgorithmWithoutOutliers.actionCell{2});
    %       title('Trained Classifier Decision Contours with Outlier Removal');
    %       subplot(2,1,2);
    %       plot(trainedClassifierWithOutliers);
    %       title('Trained Classifier Decision Contours without Outlier Removal');
    %
    %       algorithmCrossValidateOut = algo.kfolds(dataSet,5);
    %       [outlierRemovedPf, outlierRemovedPd] = prtScoreRoc(algorithmCrossValidateOut);
    %       classifierCrossValidateOut = classifier.kfolds(dataSet,5);
    %       [outlierPf, outlierPd] = prtScoreRoc(classifierCrossValidateOut);
    %       plot(outlierRemovedPf,outlierRemovedPd, outlierPf,outlierPd);
    
    
    methods
        function Obj = prtPreProcNstdOutlierRemoveTrainingOnly(varargin)
            Obj.isCrossValidateValid = true;
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function DataSet = runAction(Obj,DataSet)
            % During run we don't do anything so that we remain
            % cross-validatable
        end
        
        function DataSet = runActionOnTrainingData(Obj,DataSet)
            x = DataSet.getObservations;
            x = bsxfun(@minus,x,Obj.meanVector);
            x = bsxfun(@rdivide,x,Obj.stdVector);
            removeInd = any(abs(x) > Obj.nStd,2);
            DataSet = DataSet.removeObservations(removeInd);
        end
    end
end