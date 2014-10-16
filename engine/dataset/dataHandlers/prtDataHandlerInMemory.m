classdef prtDataHandlerInMemory < prtDataHandler
    % prtDataHandlerMatFiles Provide an interface 
    % 
    % h = prtDataHandlerInMemory('dataSet',prtDataGenUnimodal(1000));
    % ds = h.getBlock(1); 
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
    properties

        dataSet
    end
    
    methods
        
        function self = prtDataHandlerInMemory(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function ds = getNextBlock(self)
            ds = self.getBlock(1);
        end
        
        function ds = getBlock(self,i)
            if i == 1
                ds = self.dataSet;
            else
                error('prt:prtDataHandlerInMemory:oneBlock','By definition a prtDataHandlerInMemory has only one block');
            end
        end
        
        function nBlocks = getNumBlocks(self) %#ok<MANU>
            nBlocks = 1;
        end
        
        function outputClass = getDataSetType(self) 
            outputClass = class(self.dataSet);
        end
    end
end
