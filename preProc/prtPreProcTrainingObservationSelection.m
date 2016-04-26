classdef prtPreProcTrainingObservationSelection < prtPreProc
    % prtPreProcEnergyNormalizeRows Normalize the rows of the data to have unit
    % energy
    %







    properties (SetAccess=private)
        
        name = 'Observation Selection'  %  MinMax Rows
        nameAbbreviation = 'OSel'  % MMR
    end
    
    properties
        selectionFunction = @(s)true
    end
    
    methods
        
        function self = prtPreProcTrainingObservationSelection(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,~)
            return
        end
        
        function xIn = runActionFast(~,xIn,~)
            return
        end
        
        
        function DataSet = runAction(~,DataSet)
            return
        end
        
        function DataSet = runActionOnTrainingData(self,DataSet)
            DataSet = DataSet.select(self.selectionFunction);
        end
    end
    
end
