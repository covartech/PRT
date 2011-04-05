classdef prtBrvVbOnline
    properties
        vbOnlineD = 100;
        vbOnlineTau = 100;
        vbOnlineKappa = 0.01; % (0.5 1] to ensure convergence
        vbOnlineT = 0;
        
        vbOnlineUseStaticLambda = false; % false uses Sato method
        vbOnlineStaticLambda = 0.9;
        
        vbOnlineBatchSize = 1;
        vbOnlineInitialBatchSize = 10;
    end
    properties (Dependent)
        vbOnlineLambda
    end
    methods
        function val = get.vbOnlineLambda(obj)
            if ~obj.vbOnlineUseStaticLambda
                % This is the Blei adaptation.
                val = 1-(obj.vbOnlineTau + obj.vbOnlineT)^(-obj.vbOnlineKappa);
                
                % This is the SATO version and is only correct if we
                % actually update using eta not lambda (see equation 3.9)
                % val = 1./((obj.vbOnlineT - 2)*obj.vbOnlineKappa + obj.vbOnlineTau);
            else
                val = obj.vbOnlineStaticLambda;
            end
        end
        function  [obj, training] = vbOnline(obj, x)
            
            D = size(x,1);
            for iStep = 1:obj.vbMaxIterations
                
                if iStep == 1
                    cX = x(prtRvUtilRandomSample(D,obj.vbOnlineInitialBatchSize),:);
                    
                    [obj, priorObj, training] = obj.vbInitialize(cX);
                    obj = obj.vbM(priorObj, cX, training);
                    
                else
                    cX = x(prtRvUtilRandomSample(D,obj.vbOnlineBatchSize),:);
                    [obj, training] = obj.vbOnlineUpdate(priorObj, cX);
                end
                
                if obj.vbVerbosePlot
                    vbIterationPlot(obj, priorObj, cX, training);
                end
                
            end
        end
    end
    methods (Abstract)
        [obj, training] = vbOnlineUpdate(obj, x);
    end
end