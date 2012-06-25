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
            value = cell(size(key));
            uKeys = unique(key);
            
            %this should be significantly faster for large vectors of keys,
            %which, btw, you should use instead of iterating over individual keys
            for uKeyInd = 1:length(uKeys)
                keyInds = find(key == uKeys(uKeyInd));
                refInds = find(uKeys(uKeyInd) == obj.integerKeys,1);
                
                if isempty(refInds)
                    value(keyInds) = {sprintf('Class %d',uKeys(uKeyInd))};
                else
                    value(keyInds) = {obj.cellValues{refInds}};
                end
            end
            
            %             for i = 1:length(key)
            %                 ind = find(key(i) == obj.integerKeys, 1);
            %                 if isempty(ind)
            %                     value{i} = sprintf('Class %d',key(i));
            %                 else
            %                     value{i} = obj.cellValues{ind};
            %                 end
            %             end
            %Don't return a cell in this case
            if length(key) == 1
                value = value{1};
            end
        end
    end
end
            
            