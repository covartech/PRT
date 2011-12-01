% PRTBRVVBONLINE - PRT BRV Variational Bayes Online Inference parameters
%   Contains properties and methods that are useful for prtBrv objects that
%   impliment online Variational Bayes methods. It abstracts that the
%   method vbOnlineUpdate and impliments vbOnline().
%
% This is currently in alpha and should not be used.
classdef prtBrvVbOnline
    properties
        vbOnlineD = 100;
        vbOnlineTau = 100;
        vbOnlineKappa = 0.95; % (0.5 1] to ensure convergence
        vbOnlineT = 0;
        
        vbOnlineUseStaticLambda = false; % false uses Blei method
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
                val = (obj.vbOnlineTau + obj.vbOnlineT)^(-obj.vbOnlineKappa);
                
                % This is the SATO version and is only correct if we
                % actually update using eta not lambda (see equation 3.9)
                % val = 1./((obj.vbOnlineT - 2)*obj.vbOnlineKappa + obj.vbOnlineTau);
            else
                val = obj.vbOnlineStaticLambda;
            end
        end
        function  [obj, training] = vbOnline(obj, x)
            
            D = size(x,1);
            kldByIteration = zeros(obj.vbMaxIterations,1);
            for iStep = 1:obj.vbMaxIterations
                
                if iStep == 1
                    cX = x(prtRvUtilRandomSample(D,obj.vbOnlineInitialBatchSize),:);
                    
                    [initObj, priorObj, training] = obj.vbInitialize(cX);
                    
                    obj.vbOnlineT = 0;
                    [obj, training] = obj.vbOnlineUpdate(priorObj, cX, training);
                    
                else
                    
                    cX = x(prtRvUtilRandomSample(D,obj.vbOnlineBatchSize),:);
                    [obj, training] = obj.vbOnlineUpdate(priorObj, cX);
                    
                end
                
                kldByIteration(iStep) = -training.negativeFreeEnergy;
                
                training.iterations.negativeFreeEnergy(1:iStep) = -kldByIteration(1:iStep);
                
                if mod(iStep-1,obj.vbVerbosePlot)==0 || iStep == obj.vbMaxIterations
                    vbIterationPlot(obj, priorObj, cX, training);
                    
                    if obj.vbVerboseMovie
                        if isempty(obj.vbVerboseMovieFrames)
                            obj.vbVerboseMovieFrames = getframe(gcf);
                        else
                            obj.vbVerboseMovieFrames(end+1) = getframe(gcf);
                        end
                    end
                    drawnow;
                end
                
            end
        end
    end
   
    methods (Abstract)
        [obj, training] = vbOnlineUpdate(obj, x);
    end
end