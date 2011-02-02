classdef prtBlockSourceDataSet < prtBlock
    
    properties
        dataSet
    end
    
    methods
        function Obj = prtBlockSourceDataSet(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.nInputs = 0;
            Obj.inputNames = {};
            Obj.inputTypes = {};
            
            Obj.nOutputs = 1;
            Obj.outputNames = {'Output Data Set'};
            Obj.outputTypes = {'DataSet'};
        end
        function Obj = train(Obj)
            %do nada
        end
        function output = run(Obj)
            output = Obj.dataSet;
        end
        function varargout = drawBlock(varargin)
        end
    end
end