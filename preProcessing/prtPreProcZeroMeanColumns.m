classdef prtPreProcZeroMeanColumns < prtPreProc
    % prtPreProcZeroMeanColumns   Zero mean feature columns
    %
    %   ZMC = prtPreProcZeroMeanColumns creates an object that removes the
    %   mean from each column (feature) of a data set.
    %
    %   prtPreProcZeroMeanColumns has no user settable properties.
    %
    %   A prtPreProcZeroMeanColumns object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       
    %   dataSet = dataSet.retainFeatures(1:2);
    %   zmc = prtPreProcZeroMeanColumns;   
    %                                    
    %   zmc = zmc.train(dataSet);      
    %   dataSetNew = zmc.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title(sprintf('Mean: %s',mat2str(mean(dataSet.getObservations),2)))
    %   subplot(2,1,2); plot(dataSetNew);
    %   title(sprintf('Mean: %s',mat2str(mean(dataSetNew.getObservations),2)))
    %
    %   See Also: prtPreProcPca, prtPreProcHistEq, preProcLogDisc
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Zero-Mean Columns'
        nameAbbreviation = 'ZMC'
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
        function Obj = prtPreProcZeroMeanColumns(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.meanVector = nanmean(DataSet.getObservations(),1);
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,Obj.meanVector));
        end
        
    end
    
end