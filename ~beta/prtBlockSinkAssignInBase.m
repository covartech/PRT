classdef prtBlockSinkAssignInBase < prtBlock
    
    properties
        varName = 'prtBlockSinkAssignInBaseVar';
    end
    
    methods
        function Obj = prtBlockSinkAssignInBase(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.nInputs = 1;
            Obj.inputNames = {'Input'};
            Obj.inputTypes = {'typeOnegative'};
            
            Obj.nOutputs = 0;
        end
        
        function Obj = train(Obj,input)
            assignin('base',Obj.varName,input);
        end
        
        function input = run(Obj,input)
            assignin('base',Obj.varName,input);
        end
        
        function varargout = drawBlock(varargin)
        end
    end
end