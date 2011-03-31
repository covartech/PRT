classdef prtBrvVbOnline
    properties
        vbOnlineD = 100;
        vbOnlineTau = 20;
        vbOnlineKappa = 0.; % (0.5 1] to ensure convergence
        vbOnlineT = 0;
        
        vbOnlineUseStaticLambda = false; % false uses Sato method
        vbOnlineStaticLambda = 0.9;
        
        vbOnlineBatchSize = 10;
    end
    properties (Dependent)
        vbOnlineLambda
    end
    methods
        function val = get.vbOnlineLambda(obj)
            if ~obj.vbOnlineUseStaticLambda
                val = (obj.vbOnlineTau + obj.vbOnlineT)^(-obj.vbOnlineKappa); % 1 - 1./((obj.vbOnlineT -2)*obj.vbOnlineKappa + obj.vbOnlineTau);
            else
                val = obj.vbOnlineStaticLambda;
            end
        end
        function  [obj, training] = vbOnline(obj, x)
            
            D = size(x,1);
            for iStep = 1:obj.vbMaxIterations
                cX = x(prtRvUtilRandomSample(D,obj.vbOnlineBatchSize),:);
                
                if iStep == 1
                    [obj, priorObj, training] = obj.vbInitialize(cX);
                    obj = obj.vbM(priorObj, cX, training);
                    
                else
                    [obj, training] = obj.vbOnlineUpdate(cX);
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