classdef prtMapReduceStd < prtMapReduce
    % prtMapReduceStd < prtMapReduce

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


    properties
        mean = [];
    end
    
    methods
        function self = preMapReduceProcess(self,dataSetBig)
            if isempty(self.mean)
                disp('calculating MEAN... once');
                self.mean = run(prtMapReduceMean,dataSetBig);
            end
        end
        
        function map = mapFn(self,dataSet) %#ok<INUSL>
            map = struct('sumSquared',sum(dataSet.X.^2),'counts',size(dataSet.X,1));
        end
        
        function reduce = reduceFn(self,maps)
            mapStructs = cat(1,maps{:});
            squared = sum(cat(1,mapStructs.sumSquared));
            squared = squared./sum(cat(1,mapStructs.counts));
            reduce = sqrt(squared - self.mean.^2);
        end
    end
    
end
