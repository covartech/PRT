classdef prtPreProcNstdOutlierRemove < prtPreProc
    % prtPreProcNstdOutlierRemove  Removes outliers from a prtDataSet
    %
    %   NSTDOUT = prtPreProcNstdOutlierRemove creates a pre-processing
    %   object that removes observations where any of the feature values is
    %   more then set number of standard deviations from the mean of that feature.
    % 
    %   prtPreProcNstdOutlierRemove has the following properties:
    %
    %   nStd    - The number of standard deviations at which to remove
    %             an observation (default = 3)
    %
    %   A prtPreProcNstdOutlierRemove object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Example:
    %
    %   dataSet = prtDataGenUnimodal;               % Load a data set
    %   outlier = prtDataSetClass([-10 -10],1);     % Insert an outlier
    %   dataSet = catObservations(dataSet,outlier); % Concatenate
    %
    %   nStdRemove = prtPreProcNstdOutlierRemove;  % Create a prtPreProc Object
    %
    %   nStdRemove = nStdRemove.train(dataSet);    % Train 
    %   dataSetNew = nStdRemove.run(dataSet);      % Run
    % 
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('NstdOutlierRemove Data');
    %
    %   See Also: prtPreProc,
    %   prtOutlierRemoval,prtPreProcNstdOutlierRemove,
    %   prtOutlierRemovalMissingData,
    %   prtPreProcNstdOutlierRemoveTrainingOnly, prtOutlierRemovalNStd,
    %   prtPreProcPca, prtPreProcPls, prtPreProcHistEq,
    %   prtPreProcZeroMeanColumns, prtPreProcLda, prtPreProcZeroMeanRows,
    %   prtPreProcLogDisc, prtPreProcZmuv, prtPreProcMinMaxRows                    
    
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Standard Deviation Based Outlier Removal'; % Standard Deviation Based Outlier Removal
        nameAbbreviation = 'nStd' % nStd
        isSupervised = false;     % False
        
    end
    
    properties
        nStd = 3;   % The number of standard deviations beyond which to remove data
    end
    properties (SetAccess=private, Hidden = true)
        % General Classifier Properties
        stdVector = [];
        meanVector = [];
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcNstdOutlierRemove(varargin)
            Obj.isCrossValidateValid = false;  %can't cross validate because nStd changes the size of datasets
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods
        function Obj = set.nStd(Obj,value)
            if ~isnumeric(value) || ~isscalar(value) || value < 1 || round(value) ~= value
                error('prt:prtPreProcPca','valueonents (%s) must be a positive scalar integer',mat2str(value));
            end
            Obj.nStd = value;
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.meanVector = nanmean(DataSet.getObservations(),1);
            Obj.stdVector = nanstd(DataSet.getObservations(),1);
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            x = DataSet.getObservations;
            x = bsxfun(@minus,x,Obj.meanVector);
            x = bsxfun(@rdivide,x,Obj.stdVector);
            removeInd = any(abs(x) > Obj.nStd,2);
            DataSet = DataSet.removeObservations(removeInd);
        end
        
    end
    
end