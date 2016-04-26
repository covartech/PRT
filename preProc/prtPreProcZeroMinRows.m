classdef prtPreProcZeroMinRows < prtPreProc
    % prtPreProcZeroMinRows  Subtract the min all rows of the data
    %
    %   EnergyNorm = prtPreProcZeroMinRows creates an min zero
    %   pre processing object. A prtPreProcZeroMinRows object ensures that
    %   each observation vector has a min of zero.
    % 
    %   prtPreProcZeroMinRows has no user settable properties.
    %
    %   A prtPreProcZeroMinRows object also inherits all properties and
    %   functions from the prtAction class.
    %
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       
    %   dataSet = dataSet.retainFeatures(1:3);
    %   zeroMin = prtPreProcZeroMinRows;  
    %                                  
    %   zeroMin = zeroMin.train(dataSet);  
    %   dataSetNew = zeroMin.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('EnergyNorm Data');
    %







    properties (SetAccess=private)
        % Required by prtAction
        name = 'Zero Min Rows'
        nameAbbreviation = 'ZMR'
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcZeroMinRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet)
            if DataSet.nFeatures < 2
                error('prt:prtPreProcZeroMinRows:tooFewFeatures','prtPreProcZeroMinRows requires a data set with at least 2 dimensions, but provided data set only has %d',DataSet.nFeatures);
            end
            
            theData = DataSet.getObservations;
            
            theData = bsxfun(@minus,theData,min(theData,[],2));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end
