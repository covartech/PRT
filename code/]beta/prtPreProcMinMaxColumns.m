classdef prtPreProcMinMaxColumns < prtPreProc

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


    properties (SetAccess=private)
        
        name = 'MinMax Columns'  %  MinMax Rows
        nameAbbreviation = 'MMC'  % MMR
    end
    
    properties
        %no properties
        minVals = [];
        maxVals = [];
    end
    
    methods
        
        function self = prtPreProcMinMaxColumns(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,DataSet) %#ok<INUSD>
            %do nothing
            self.minVals = min(DataSet.getObservations);
            self.maxVals = max(DataSet.getObservations);
            invalidInds = find(self.minVals == self.maxVals);
            %Do nothing for invalid indices
            self.minVals(invalidInds) = 0;
            self.maxVals(invalidInds) = 1;
        end
        
        function DataSet = runAction(self,DataSet)
            
            theData = DataSet.getObservations;
            
            theData = bsxfun(@minus,theData,self.minVals);
            theData = bsxfun(@rdivide,theData,self.maxVals - self.minVals);
            
            %what should we do about outliers?  they will not be zero or
            %one...
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end
