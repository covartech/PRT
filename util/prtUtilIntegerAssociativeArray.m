classdef prtUtilIntegerAssociativeArray
    % prtUtilIntegerAssociativeArray
    % xxx Need Help xxx
    % To do: make this faster by allocating large chunks of data...
    
    properties 
        integerKeys = [];
        cellValues = {};
    end
    
    methods
        
        function [out,integerSwaps] = combine(self,in2)
            
            keys1 = self.integerKeys;
            keys1 = keys1(:);
            
            vals1 = self.get(keys1);
            vals1 = vals1(:);
            
            keys2 = in2.integerKeys;
            keys2 = keys2(:);
            
            vals2 = self.get(keys2);
            vals2 = vals2(:);
            
            [unionKeys,ind1,ind2] = union(keys1,keys2);
            commonKeys = intersect(keys1,keys2);
            
            integerSwaps = [];
            newKey = max(unionKeys)+1;
            for i = 1:length(unionKeys)
                theKey = unionKeys(i);
                
                %Handle duplicate values with mis-matched indices
                % Note, technically this is not correct for an
                % integerAssocArray; this enforces that during combining,
                % no duplicate keys exist... this belongs elsewhere...
                % this works for the places we use it in the PRT... but is
                % not food for assoc.arrays in general... boo.
                if ~self.containsKey(theKey); %if we don't have the key, it's OK to add it
                    self = self.put(theKey,in2.get(theKey));
                else
                    if ~isequal(self.get(theKey),in2.get(theKey)) && any(strcmpi(self.get(theKey),in2.cellValues))
                        
                        changeKey = in2.integerKeys(strcmpi(self.get(theKey),in2.cellValues));
                        integerSwaps = cat(1,integerSwaps,[changeKey,theKey]);
                        in2 = in2.remove(changeKey);
                        
                        %Handle new name
                    elseif ~isequal(self.get(theKey),in2.get(theKey))
                        in2.integerKeys(in2.integerKeys == theKey) = newKey;
                        integerSwaps = cat(1,integerSwaps,[theKey,newKey]);
                        newKey = newKey + 1;
                    end
                end
            end
            
            %we should be OK nowl integerSwaps tells us which keys in in2
            %became new keys, and this should run, since any conflicitng
            %keys are no longer conflicting
            out = merge(self,in2); 
        end
        
        function out = merge(self,in2)
            
            
            keys1 = self.integerKeys;
            keys1 = keys1(:);
            
            vals1 = self.get(keys1);
            if ~isa(vals1,'cell')
                vals1 = {vals1};
            end
            vals1 = vals1(:);
            
            keys2 = in2.integerKeys;
            keys2 = keys2(:);
            
            vals2 = in2.get(keys2);
            if ~isa(vals2,'cell')
                vals2 = {vals2};
            end
            vals2 = vals2(:);
            
            [unionKeys,ind1,ind2] = union(keys1,keys2);
            commonKeys = intersect(keys1,keys2);
            
            if ~isequal(self.get(commonKeys),in2.get(commonKeys))
                error('prtUtilIntegerAssociativeArray:cannotMerge','Input arguments have keys in common with different values');
            end
            
            out = prtUtilIntegerAssociativeArray(unionKeys(:),cat(1,vals1(ind1),vals2(ind2)));
            
        end
        
        function obj = prtUtilIntegerAssociativeArray(integerKeys,cellValues)
            
            if nargin == 0
                return;
            else
                if ~isa(cellValues,'cell')
                    cellValues = {cellValues};
                end
                if ~isequal(size(integerKeys),size(cellValues)) && (~isempty(integerKeys) && ~isempty(cellValues))
                    error('incompatible key and cell sizes');
                end
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
        
        function self = replaceKeys(self,oldKeys,newKeys)
            %self = replaceKeys(self,oldKeys,newKeys)
            for i = 1:length(oldKeys)
                self.integerKeys(self.integerKeys == oldKeys(i)) = newKeys(i);
            end
        end
        
        function self = retain(self,keys)
            
            keepLocs = false(1,length(self.integerKeys));
            if isempty(keepLocs)
                return
            end
            for i = 1:length(keys)
                keepLocs = keepLocs | self.integerKeys == keys(i);
            end
            self.integerKeys = self.integerKeys(keepLocs);
            self.cellValues = self.cellValues(keepLocs);
        end
        
        function self = remove(self,keys)
            removeLocs = false(1,length(self.integerKeys));
            for i = 1:length(keys)
                removeLocs = removeLocs | self.integerKeys == keys(i);
            end
            self.integerKeys = self.integerKeys(~removeLocs);
            self.cellValues = self.cellValues(~removeLocs);
        end
        
        function value = get(obj,key)
            
            value = cell(1,length(key));
            for i = 1:length(key)
                ind = find(key(i) == obj.integerKeys, 1);
                if isempty(ind)
                    value{i} = [];
                else
                    value{i} = obj.cellValues{ind};
                end
            end
            %Don't return a cell in this case
            if length(key) == 1
                value = value{1};
            end
        end
        
        function empty = isempty(obj)
            empty = isempty(obj.integerKeys);
        end
    end
end
            
            