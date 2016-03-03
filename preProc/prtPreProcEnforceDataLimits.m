classdef prtPreProcEnforceDataLimits < prtPreProcFunction
    % prtPreProcEnforceDataLimits   Applies a function to observations
    %
    %   

% Copyright (c) 2014 CoVar Applied Technologies
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
    end
    properties
        dataLimits = [0 inf];
    end
        
    methods
        function self = prtPreProcEnforceDataLimits(varargin)
            self.operateOnMatrix = true; % Set to true for faster operation, but be careful

            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.isTrained = true;
        end
        
        function self = set.dataLimits(self,val)
            self.dataLimits = val;
            self.transformationFunction = @(x)cvrEnforceDataLimits(x,self.dataLimits);
        end
    end
    
    
end
