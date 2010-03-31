classdef prtRegressGP < prtRegress
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Maximum a Posteriori'
        nameAbbreviation = 'MAP'
        isSupervised = true;
    end
    
    properties
        % Optional parameters
        covarianceFunction = @(x1,x2)prtKernelQuadExpCovariance(x1,x2, 1, 4, 0, 0);
        noiseVariance = 0.01;
        
        % Infered parameters
        CN = [];
        weights = [];
        
    end
    
    methods
        
        function Obj = prtRegressGp(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.CN = feval(Obj.covarianceFunction, DataSet.getObservations(), DataSet.getObservations()) + Obj.noiseVariance*eye(DataSet.nObservations);
            
            Obj.weights = Obj.CN\DataSet.getTargets();
        end
        
        function DataSet = runAction(Obj,DataSet)
            k = feval(Obj.covarianceFunction, Obj.DataSet.getObservations(), DataSet.getObservations());
            c = diag(feval(Obj.covarianceFunction, DataSet.getObservations(), DataSet.getObservations())) + Obj.noiseVariance;
            
            DataSet = prtDataSetUnLabeled(k'*Obj.weights);
            DataSet.UserData.variance = c - prtUtilCalcDiagXcInvXT(k', Obj.CN);
        end
        
    end
    
end