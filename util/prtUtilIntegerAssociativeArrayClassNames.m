classdef prtUtilIntegerAssociativeArrayClassNames < prtUtilIntegerAssociativeArray
    % prtUtilIntegerAssociativeArray
    % xxx Need Help xxx
    
    methods
        function self = merge(self,other)
            temp = merge@prtUtilIntegerAssociativeArray(self,other);
            self = prtUtilIntegerAssociativeArrayClassNames(temp.integerKeys,temp.cellValues);
        end
            
        function obj = prtUtilIntegerAssociativeArrayClassNames(integerKeys,cellValues)
            
            if nargin == 0
                return;
            else
                obj.integerKeys = integerKeys;
                obj.cellValues = cellValues;
            end
        end
        
        function value = get(obj,key)
            value = cell(1,length(key));
            for i = 1:length(key)
                ind = find(key(i) == obj.integerKeys, 1);
                if isempty(ind)
                    value{i} = sprintf('Class %d',key(i));
                else
                    value{i} = obj.cellValues{ind};
                end
            end
            %Don't return a cell in this case
            if length(key) == 1
                value = value{1};
            end
        end
    end
end
            
            