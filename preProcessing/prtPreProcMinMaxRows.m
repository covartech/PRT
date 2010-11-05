classdef prtPreProcMinMaxRows < prtPreProc
    % prtPreProcMinMaxRows  Min (0), Max (1) all rows of the data
    %
    %   LOGDISC = prtPreProcMinMaxRows creates a min/max rows pre
    %   processing object. A prtPreProcMinMaxRows object linearly scales
    %   the input observations so that each row (observation) has a min of
    %   0 and a max of 1.
    % 
    %   prtPreProcMinMaxRows has no user settable properties.
    %
    %   A prtPreProcMinMaxRows object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Note for two-dimensional data sets, min/max rows will result in all
    %   observations taking values 1 or 2
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       
    %   dataSet = dataSet.retainFeatures(1:3);
    %   logDisc = prtPreProcMinMaxRows;  
    %                                  
    %   logDisc = logDisc.train(dataSet);  
    %   dataSetNew = logDisc.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('MinMaxRows Data');
    %
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'MinMax Rows'
        nameAbbreviation = 'MMR'
        isSupervised = false;
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcMinMaxRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet)
            if DataSet.nFeatures < 2
                error('prt:prtPreProcMinMaxRows:tooFewFeatures','prtPreProcMinMaxRows requires a data set with at least 2 dimensions, but provided data set only has %d',DataSet.nFeatures);
            end
            
            theData = DataSet.getObservations;
            
            minVals = min(theData,[],2);
            maxVals = max(theData,[],2);
            theData = bsxfun(@rdivide,bsxfun(@minus,theData,minVals),(maxVals-minVals));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end