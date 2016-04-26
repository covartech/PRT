classdef prtPreProcEnergyNormalizeRowsWithEnergy < prtPreProc
    % prtPreProcEnergyNormalizeRows Normalize the rows of the data to have unit
    % energy
    %







    properties (SetAccess=private)
        
        name = 'Energy Normalize Rows With Energy'  %  MinMax Rows
        nameAbbreviation = 'ENRWE'  % MMR
    end
    
    properties
        %no properties
        energyOffset = 0;
    end
    
    methods
        
        function self = prtPreProcEnergyNormalizeRowsWithEnergy(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,DataSet) %#ok<INUSD>
            %do nothing
        end
        
        function DataSet = runAction(self,DataSet) %#ok<MANU>
            
            theData = DataSet.getObservations;
            dataEnergy = sqrt(sum(theData.^2,2));
            theData = bsxfun(@rdivide,theData,self.energyOffset + dataEnergy);
            theData = cat(2,dataEnergy,theData);
            DataSet = DataSet.setObservations(theData);
        end
        
        function xOut = runActionFast(self,xIn,ds) %#ok<INUSD>
            
            dataEnergy = sqrt(sum(xIn.^2,2));
            xOut = bsxfun(@rdivide,xIn,self.energyOffset + dataEnergy);
            xOut = cat(2,dataEnergy,xOut);
        end
    end
    
    
    methods (Hidden)
        function str = exportSimpleText(self)
            titleText = sprintf('%% prtPreProcEnergyNormalizeRows\n');
            energyOffsetText = prtUtilMatrixToText(full(self.energyOffset),'varName','energyOffset');
            str = sprintf('%s%s',titleText,energyOffsetText); % No parameters 
        end
    end
    
end
