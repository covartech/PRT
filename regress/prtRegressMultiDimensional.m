classdef prtRegressMultiDimensional < prtRegress
    % prtRegressMultiDimensional
    %   Iteratively runs a baseRegressor for each output dimension of a regression dataset
    %   baseRegressor can be an algorithm capable of running on prtDataSetRegress
    
    properties (SetAccess=private)
        name = 'Multi-Dimensional Output Wrapper Regression'
        nameAbbreviation = 'MDOW'
    end
    
    properties
        baseRegressor = prtRegressLslr;
        regressors = cell(0);
        nDimensions
    end

    methods
        function self = prtRegressMultiDimensional(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,ds)
            self.nDimensions = ds.nTargetDimensions;
            
            self.regressors = cell(1,self.nDimensions);
            for iDim = 1:self.nDimensions
                self.regressors{iDim} = train(self.baseRegressor, ds.retainTargets(iDim));
            end
        end
        
        function ds = runAction(self,ds)
            x = zeros(ds.nObservations,self.nDimensions);
            for iDim = 1:self.nDimensions
                x(:,iDim) = getObservations(run(self.regressors{iDim},ds));
            end
            ds.X = x;
        end
    end
    
end
