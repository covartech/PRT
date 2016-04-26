classdef prtPreProcEnergyNorm < prtPreProc
    % prtPreProcEnergyNorm  Normalize the energy of all rows of the data
    %
    %   EnergyNorm = prtPreProcEnergyNorm creates an energy normalize rows
    %   pre processing object. A prtPreProcEnergyNorm object scales
    %   the input observations so that each row has unit energy.
    % 
    %   prtPreProcEnergyNorm has no user settable properties.
    %
    %   A prtPreProcEnergyNorm object also inherits all properties and
    %   functions from the prtAction class.
    %
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       
    %   dataSet = dataSet.retainFeatures(1:3);
    %   energyNorm = prtPreProcEnergyNorm;  
    %                                  
    %   energyNorm = energyNorm.train(dataSet);  
    %   dataSetNew = energyNorm.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('EnergyNorm Data');
    %







    properties (SetAccess=private)
        % Required by prtAction
        name = 'Energy Norm Rows'
        nameAbbreviation = 'ENR'
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcEnergyNorm(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet)
            if DataSet.nFeatures < 2
                error('prt:prtPreProcMinMaxRows:tooFewFeatures','prtPreProcMinMaxRows requires a data set with at least 2 dimensions, but provided data set only has %d',DataSet.nFeatures);
            end
            
            theData = DataSet.getObservations;
            
            theData = bsxfun(@rdivide,theData,sqrt(sum(theData.^2,2)));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end
