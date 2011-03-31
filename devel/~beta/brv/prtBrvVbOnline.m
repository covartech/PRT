classdef prtBrvVbOnline
    properties
        vbOnlineD = 100;
        vbOnlineTau = 20;
        vbOnlineKappa = 0.01;
        vbOnlineT = 0;
        
        vbOnlineBatchSize = 10;
    end
    properties (Dependent)
        vbOnlineLambda
    end
    methods
        function val = get.vbOnlineLambda(obj)
            %val = (obj.vbOnlineTau + obj.vbOnlineT)^(-obj.vbOnlineKappa); % 1 - 1./((obj.vbOnlineT -2)*obj.vbOnlineKappa + obj.vbOnlineTau);
            val = 0.001;
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