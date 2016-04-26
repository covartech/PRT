classdef prtPreProcMinMaxRows < prtPreProc
    % prtPreProcMinMaxRows Minimize and maximize all rows of the data
    %
    %   MINMAX = prtPreProcMinMaxRows creates a min/max rows pre
    %   processing object. A prtPreProcMinMaxRows object linearly scales
    %   the input observations so that each row (observation) has a minimum
    %   of 0 and a maximum of 1.
    % 
    %   prtPreProcMinMaxRows has no user settable properties.
    %
    %   A prtPreProcMinMaxRows object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Note for two-dimensional data sets, min/max rows will result in all
    %   observations taking values 0 or 1.
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;              % Load a data set
    %   dataSet = dataSet.retainFeatures(1:3); % Retain the first 3 features
    %   logDisc = prtPreProcMinMaxRows;        % Create the pre processing 
    %                                          % object
    %   minmax = logDisc.train(dataSet);       % Train
    %   dataSetNew = minmax.run(dataSet);      % Run
    % 
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('MinMaxRows Data');
    %
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows







    properties (SetAccess=private)
        
        name = 'MinMax Rows'  %  MinMax Rows
        nameAbbreviation = 'MMR'  % MMR
    end
    
    properties
        %no properties
    end
    
    methods
        
        function Obj = prtPreProcMinMaxRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet) %#ok<INUSD>
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
