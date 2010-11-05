classdef prtPreProcZeroMeanRows < prtPreProc
    % prtPreProcZeroMeanRows   Zero mean observations (rows)
    %
    %   ZMC = prtPreProcZeroMeanRows creates an object that removes the
    %   mean from each row (observation) of a data set.
    %
    %   prtPreProcZeroMeanRows has no user settable properties.
    %
    %   A prtPreProcZeroMeanRows object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       
    %   dataSet = dataSet.retainFeatures(1:3);
    %   zmr = prtPreProcZeroMeanRows;   
    %                                    
    %   zmr = zmr.train(dataSet);      
    %   dataSetNew = zmr.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   subplot(2,1,2); plot(dataSetNew);
    %
    %   See Also: prtPreProcPca, prtPreProcHistEq, preProcLogDisc
    
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Zero-Mean Rows'
        nameAbbreviation = 'ZMR'
        isSupervised = false;
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
        meanVector = [];           % A vector of the means
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcZeroMeanRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,mean(DataSet.getObservations,2)));
        end
        
    end
    
end