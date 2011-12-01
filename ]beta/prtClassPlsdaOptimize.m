classdef prtClassPlsdaOptimize < prtClassPlsda
    
    properties
        internalPlsda = prtClassPlsda;
        nComponentsRange = 3:40;
    end
    methods
        
        function Obj = prtClassPlsdaOptimize(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            Obj = optimize(Obj.internalPlsda, DataSet, @(C,DS)prtEvalPercentCorrect(C,DS,2), 'nComponents', Obj.nComponentsRange);
            fprintf('optimal # components: %d\n',Obj.nComponents);
            Obj = trainAction@prtClassPlsda(Obj, DataSet);
            %Note: this outputs an object of class prtClassPlsda; this can
            %cause all manner of... confusion
        end
        
    end
end