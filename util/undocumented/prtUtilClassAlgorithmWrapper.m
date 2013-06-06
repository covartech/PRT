classdef prtUtilClassAlgorithmWrapper < prtClass

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
        
        name = 'AlgorithmWrapper'
        nameAbbreviation = 'AlgoWrap'
        isNativeMary = false; 
    end
    
    properties 
        trainedAlgorithm
    end
    
    methods
        
        function self = prtUtilClassAlgorithmWrapper(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.isTrained = true;
        end
        
        function self = set.trainedAlgorithm(self,val)
            self.trainedAlgorithm = val;
            self.dataSet = val.dataSet;
            self.dataSetSummary = val.dataSetSummary;
            self.yieldsMaryOutput = val.actionCell{end}.yieldsMaryOutput;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            self.trainedAlgorithm = self.trainedAlgorithm.train(dataSet);
        end
        
        function dataSet = runAction(self,dataSet)
            dataSet = self.trainedAlgorithm.run(dataSet);
        end
        
    end
    
end
