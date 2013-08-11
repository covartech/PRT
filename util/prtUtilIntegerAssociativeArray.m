classdef prtUtilIntegerAssociativeArray
    % prtUtilIntegerAssociativeArray
    % xxx Need Help xxx
    % To do: make this faster by allocating large chunks of data...

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


    properties 
        integerKeys = [];
        cellValues = {};
    end
    
    methods
        
        function [out,integerSwaps] = combine(self,in2)
            
            keys1 = self.integerKeys;
            keys1 = keys1(:);
            
            keys2 = in2.integerKeys;
            keys2 = keys2(:);
            
            unionKeys = union(keys1,keys2);
            
            integerSwaps = [];
            newKey = max(unionKeys)+1;
            for i = 1:length(unionKeys)
                theKey = unionKeys(i);
                
                val1 = self.get(theKey); val1 = val1{1};
                val2 = in2.get(theKey); val2 = val2{1};
                    
                %Handle duplicate values with mis-matched indices
                % Note, technically this is not correct for an
                % integerAssocArray; this enforces that during combining,
                % no duplicate keys exist... this belongs elsewhere...
                % this works for the places we use it in the PRT... but is
                % not food for assoc.arrays in general... boo.
                if ~self.containsKey(theKey) %the first one doesn't have the key it's OK to add it
                    self = self.put(theKey, val2);
                else 
                    if ~isequal(val1,val2)
                        % The two values are not the same
                        if any(strcmpi(val1,in2.cellValues))
                            % The value is somewhere in the second one.
                            % We have to find it and mark those keys to be changed
                            
                            changeKey = in2.integerKeys(strcmpi(val1,in2.cellValues));
                            integerSwaps = cat(1,integerSwaps,[changeKey,theKey]);
                            in2 = in2.remove(changeKey);
                        else
                            % The value is not in the second set but is in
                            % the first
                            in2.integerKeys(in2.integerKeys == theKey) = newKey;
                            integerSwaps = cat(1,integerSwaps,[theKey,newKey]);
                            newKey = newKey + 1;
                        end
                    else
                        % Two values are the same. Don't do anything
                    end
                end
            end
            
            %we should be OK nowl integerSwaps tells us which keys in in2
            %became new keys, and this should run, since any conflicitng
            %keys are no longer conflicting
            out = merge(self,in2); 
        end
        
        function out = merge(self,in2)
            
            persistent versionNum
            if isempty(versionNum)
                %Backwards compatible bug-fix; 2013.08.11
                % Note: ver is slow, so use persistence
                s = ver('matlab');
                versionNum = str2double(s.Version);
            end
            
            keys1 = self.integerKeys;
            keys1 = keys1(:);
            
            vals1 = self.get(keys1);
            vals1 = vals1(:);
            
            keys2 = in2.integerKeys;
            keys2 = keys2(:);
            
            vals2 = in2.get(keys2);
            vals2 = vals2(:);
            
            if versionNum >= 8
                [unionKeys,ind1,ind2] = union(keys1,keys2,'R2012a'); % Bug fix 2013-06-13
            else
                [unionKeys,ind1,ind2] = union(keys1,keys2);
            end
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
            
            
