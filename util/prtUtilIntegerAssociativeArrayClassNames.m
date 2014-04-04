classdef prtUtilIntegerAssociativeArrayClassNames < prtUtilIntegerAssociativeArray
    % prtUtilIntegerAssociativeArray
    % xxx Need Help xxx

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
                if isnan(uKeys(uKeyInd))
                    value(isnan(key)) = {'unlabeled'};
                else
                    keyInds = find(key == uKeys(uKeyInd));
                    refInds = find(uKeys(uKeyInd) == obj.integerKeys,1);
                    
                    if isempty(refInds)
                        value(keyInds) = {sprintf('Class %d',uKeys(uKeyInd))};
                    else
                        value(keyInds) = {obj.cellValues{refInds}};
                    end
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
%             if length(key) == 1
%                 value = value{1};
%             end

            % This has been changed 2013-06-12 because it is weird to do
            % this.
        end
    end
end
            
            
