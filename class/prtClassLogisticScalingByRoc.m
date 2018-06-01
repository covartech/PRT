classdef prtClassLogisticScalingByRoc < prtClass
    % prtClassLogisticScalingByRoc Use ROC to logistically scale outputs
    %
    properties (SetAccess=private)
        name = 'Logisticaclly Scaled Confidences'
        nameAbbreviation = 'LSC'
        isNativeMary = true;
    end
    
    properties
        alpha = [.1, .9]
        farRange = [.1 .9]
    end
    properties (SetAccess=protected)
        sigmoid
    end
    
    methods
        function self = prtClassLogisticScalingByRoc(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,DataSet)
            if isa(DataSet,'prtDataSetDuf')
                r = DataSet.scoreRoc;
            else
                r = prtScoreRoc(DataSet);
            end
            if isempty(r.farDenominator) || ~isfinite(r.farDenominator)
                r.farDenominator = r.nNonTargets; % far is Pf
            end
            
            modelConfs = r.tau;
            modelFars = r.far;
            
            % We clip farLow to min(modelFars) and farHigh to max(modelFars)
            farLow = max([self.farRange(1), min(modelFars), 1e-5]);
            farHigh = min(self.farRange(2), max(modelFars));
            if farHigh < farLow
                farHigh = farLow;
            end
            
            % interp1 does not like non-uniqueness
            [uFar,uInd] = unique(modelFars);
            uConf = modelConfs(uInd);
            
            % NOTE: farLow maps to confHigh, farHigh maps to confLow
            confHigh = interp1(uFar, uConf, farLow);
            confLow = interp1(uFar, uConf, farHigh);
            
            %sigmoidFn = ecoUtilCreateSigmoidFunction(confLow, confHigh, opts.alpha);
            spread = (confHigh-confLow)./(log(1./self.alpha(1) - 1) - log(1./self.alpha(2)- 1));
            mu = confLow + spread*log(1./self.alpha(1)-1);
            
            self.sigmoid = @(x)(1./(1 + exp(-(x-mu)/spread)));
            
        end
        
        function DataSet = runAction(self,DataSet)
            DataSet.X = self.sigmoid(DataSet.X(:,1));
        end

    end
end
