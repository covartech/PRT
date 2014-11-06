classdef prtClassLrk < prtClassLr

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
        % kernel
        kernel = prtKernelDc & prtKernelRbfNdimensionScale;
    end    
    
    methods
        function self = prtClassLrk(varargin)
            self = self@prtClassLr();
            
            paramNames = varargin(1:2:end);
            if ismember('includeBias',paramNames)
                warning('prt:prtClassLrk:includeBiasIgnored','The includeBias parameter is ignored when useing kernel logistic regression');
            end
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
            %self.name = 'Logistic Regression, Kernel'; % Logistic Regression, Kernel
            %self.nameAbbreviation = 'LRK'; % LRK
        end
    end
    
    methods (Hidden)
        function [self, x] = getFeatureMapTrain(self, dataSet)
            self.kernel = train(self.kernel, dataSet);
            
            x = run_OutputDoubleArray(self.kernel, dataSet);
        end
       
        function x = getFeatureMapRun(self, dataSet)
            x = run_OutputDoubleArray(self.kernel, dataSet);
        end
    end
end
