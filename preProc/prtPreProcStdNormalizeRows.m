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
