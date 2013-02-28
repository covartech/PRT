classdef prtKernelQMetric < prtKernelBinary

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
        lambda = -0.4;
    end
    properties (SetAccess = 'protected')
        kernelCenter = [];   % The kernel center
    end
    
    methods
        
        function obj = set.lambda(obj,value)
            assert(isscalar(value) && value >= -1 && value <= 0,'lambda parameter must be scalar and between -1 and 0, value provided is %s',mat2str(value));
            obj.sigma = value;
        end
        
        function obj = prtKernelQMetric(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = trainKernel(obj,x)
            obj.kernelCenter = x;
        end
        
        function yOut = evalKernel(obj,data)
            yOut = prtKernelQMetric.qmetricEval(obj.kernelCenter,data,obj.lambda);
        end
        
    end
    
    methods (Static, Hidden = true)
        function gram = qmetricEval(x,y,lambda)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = prtDistanceQMetric(x,y,lambda);
        end
    end
end
