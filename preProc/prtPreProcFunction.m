classdef prtPreProcFunction < prtPreProc
    % prtPreProcFunction   Applies a function to observations
    %
    %   FUN = prtPreProcFunction creates a pre processing object that
    %   applies a specified function to the observations.
    %
    %   The function is set as a function handle in the property
    %   "transformationFunction" The default is @(x)(x), which does
    %   nothing.
    %
    %   A prtPreProcFunction object also inherits all properties and
    %   methods from the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       % Load a data set.
    %   dataSet = dataSet.retainFeatures(1:2);
    %   fun = prtPreProcFunction('transformationFunction',@(x)x.^2);       
    %   fun = fun.train(dataSet);       % All prtAction's must be trained
    %   dataSetNew = fun.run(dataSet);  % Normalize the data
    % 
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Dataset')
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('x.^2 Dataset')
    %
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows 







    properties (SetAccess=private)
        name = 'Function' 
        nameAbbreviation = 'FUN'
    end
    properties
        transformationFunction = @(x)x;
    end
    
    properties (Hidden)
        operateOnMatrix = false; % Set to true for faster operation, but be careful
    end
    
    methods
        function self = prtPreProcFunction(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function self = trainAction(self,ds) %#ok<INUSD>
            % Nothing to do here
        end
        
        function ds = runAction(self,ds)
           ds.X = runActionFast(self,ds.X);
        end
        
        function x = runActionFast(self,x)
            if self.operateOnMatrix
                x = feval(self.transformationFunction,x);
                
            else % operateOnRows
                xOut = repmat(self.transformationFunction(x(1,:)),size(x,1),1);
                for i = 2:size(x,1)
                    xOut(i,:) = self.transformationFunction(x(i,:));
                end
                x = xOut;
                
             end
        end
    end
    methods
        function self = set.transformationFunction(self,val)
            assert(isa(val,'function_handle'), 'transformationFunction must be a function handle that accepts at least one input argument.');
            self.transformationFunction = val;
        end
    end
    
    
    methods (Hidden = true)
        
        function yOut = runStream(self,vector)
            % yOut = runStream(self,vector)
            yOut = self.transformationFunction(vector);
        end
    end
end
