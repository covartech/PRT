classdef prtPreProcZeroMeanRows < prtPreProc
    % prtPreProcZeroMeanRows  Zero mean observations (rows)
    %
    %   ZM = prtPreProcZeroMeanRows creates an object that removes the
    %   mean from each row (observation) of a data set.
    %
    %   prtPreProcZeroMeanRows has no user settable properties.
    %
    %   A prtPreProcZeroMeanRows object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;              % Load a data set
    %   dataSet = dataSet.retainFeatures(1:3); % Use only the first 3 features 
    %   zmr = prtPreProcZeroMeanRows;          % Create a
    %                                          %  prtPreProcZeroMeanRows object                                   
    %   zmr = zmr.train(dataSet);              % Train 
    %   dataSetNew = zmr.run(dataSet);         % Run
    % 
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   subplot(2,1,2); plot(dataSetNew);
    %
    %   See Also: prtPreProc,
    %   prtOutlierRemoval,prtPreProcNstdOutlierRemove,
    %   prtOutlierRemovalMissingData,
    %   prtPreProcNstdOutlierRemoveTrainingOnly, prtOutlierRemovalNStd,
    %   prtPreProcPca, prtPreProcPls, prtPreProcHistEq,
    %   prtPreProcZeroMeanColumns, prtPreProcLda, prtPreProcZeroMeanRows,
    %   prtPreProcLogDisc, prtPreProcZmuv, prtPreProcMinMaxRows                    
        
    
    properties (SetAccess=private)
        name = 'Zero-Mean Rows' % Zero-Mean Rows
        nameAbbreviation = 'ZMR' % ZMR
        isSupervised = false; % False
    end
    
    properties
        %no properties
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcZeroMeanRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet) %#ok<INUSD>
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet) %#ok<MANU>
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,mean(DataSet.getObservations,2)));
        end
        
    end
    
end