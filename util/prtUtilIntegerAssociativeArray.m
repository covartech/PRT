classdef prtUtilIntegerAssociativeArray
    % prtUtilIntegerAssociativeArray
    
    properties 
        integerKeys = [];
        cellValues = {};
    end
    
    methods
        function obj = prtUtilIntegerAssociativeArray(obj,integerKeys,cellValues)
            
            if nargin == 0
                return;
            else
                obj.integerKeys = integerKeys;
                obj.cellValues = cellValues;
            end
        end
        
        function obj = put(obj,key,value)
            ind = find(key == obj.integerKeys, 1);
            if isempty(ind)
                ind = length(obj.integerKeys)+1;
            end
            obj.integerKeys(ind) = key;
            obj.cellValues{ind} = value;
        end
        
        function contains = containsKey(obj,key)
            ind = find(key == obj.integerKeys, 1);
            contains = ~isempty(ind);
        end
        function value = get(obj,key)
            ind = find(key == obj.integerKeys, 1);
            if isempty(ind)
                value = [];
            else
                value = obj.cellValues{ind};
            end
        end
    end
end
            
            