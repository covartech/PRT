classdef prtPreProcStdNormalizeRows < prtPreProc
    % prtPreProcStdNormalizeRows Normalize the rows of the data to have
    %    unit standard deviation
    %
    %   stdNorm = prtPreProcStdNormalizeRows creates a prtAction that will
    %     normalize the rows of a data set to have unit standard deviation.
    %
    %   stdNorm = prtPreProcStdNormalizeRows('varianceOffset',V) constructs a
    %     prtPreProcStdNormalizeRows object stdNorm with varianceOffset set
    %     to the value V.  Normalization of each row is calculated with:
    %           x = x./sqrt(var(x) + varianceOffset)
    %     By default, varianceOffset is zero.
    %     
    %   A prtPreProcStdNormalizeRows object has the following properites:
    % 
    %   varianceOffset    - An offset to help avoid dividing by zero
    %               problems
    %
    %   A prtPreProcStdNormalizeRows object also inherits all properties
    %   and functions from the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenUnimodal;           
    %   stdNorm = prtPreProcStdNormalizeRows;   % Create a prtPreProcStdNormalizeRows object
    %                        
    %   stdNorm = stdNorm.train(dataSet);       % Train the prtPreProcStdNormalizeRows object
    %   dataSetNorm = stdNorm.run(dataSet);     % Run
    % 
    %   unique(std(dataSetNorm.X,[],2))  % All close to 1; within machine
    %                                    % precision
    %  

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
        
        name = 'Standard Dev Normalize Rows'
        nameAbbreviation = 'StdNorm' 
    end
    
    properties
        varianceOffset = 0;
    end
    
    methods
        
        function self = prtPreProcStdNormalizeRows(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,dataSet) %#ok<INUSD>
            %do nothing
        end
        
        function dataSet = runAction(self,dataSet)
            x = dataSet.getObservations;

            meanVec = mean(x,2);
            x = bsxfun(@minus,x,meanVec);
            
            variance = var(x,[],2);
            variance = variance + self.varianceOffset;
            x = bsxfun(@rdivide,x,sqrt(variance));

            x = bsxfun(@plus,x,meanVec);
            
            dataSet = dataSet.setObservations(x);

        end
        
    end
    
end
