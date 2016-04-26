% PRTBRVVBONLINE - PRT BRV Variational Bayes Online Inference parameters
%   Contains properties and methods that are useful for prtBrv objects that
%   impliment online Variational Bayes methods. It abstracts that the
%   method vbOnlineUpdate and impliments vbOnline().
%
% This is currently in alpha and should not be used.





classdef prtBrvVbOnline < prtBrvVb

    
    methods (Abstract)
        [initSelf, priorSelf, training] = vbOnlineInitialize(self, x);
        [self, training] = vbOnlineUpdate(self, priorSelf, x, training, prevSelf, learningRate, D)
    end
    
    properties
        vbOnlineLearningRateFunctionHandle = @(t)(100 + t).^(-0.9); % From Wang, Paisley and Blei (2011)
        vbOnlineBatchSize = 25;
        vbOnlineFullDataSetSize = []; % If empty it is learned from a batch
        vbUseOnlineInsteadOfBatch = false;
    end
    methods
        
        % Overload the vb method to include an option to call vbOnline
        % instead of vbBatch
        function [self, training] = vb(self, x)
            if self.vbUseOnlineInsteadOfBatch
                [self, training] = vbOnline(self, x);
            else
                [self, training] = vbBatch(self, x);
            end
        end
        
        function  [self, training] = vbOnline(self, x)
            
            if isempty(self.vbOnlineFullDataSetSize)
                D = size(x,1);
            else
                D = self.vbOnlineFullDataSetSize;
            end
            
            for iStep = 1:self.vbMaxIterations
                cX = x(prtRvUtilRandomSample(D,self.vbOnlineBatchSize),:);
                learningRate =  self.vbOnlineLearningRateFunctionHandle(iStep);
                
                if iStep == 1
                    [initSelf, priorSelf] = self.vbOnlineInitialize(cX);
                    
                    [self, training] = initSelf.vbOnlineUpdate(priorSelf, cX, [], initSelf, learningRate, D);
                    
                else
                    
                    [self, training] = self.vbOnlineUpdate(priorSelf, cX, [], self, learningRate, D);
                end
                
                training.iterations.negativeFreeEnergy(1:iStep) = self.vbOnlineLearningRateFunctionHandle(1:iStep);
                
                if mod(iStep-1,self.vbVerbosePlot)==0 || iStep == self.vbMaxIterations
                    vbIterationPlot(self, priorSelf, cX, training);
                    
                    if self.vbVerboseMovie
                        if isempty(self.vbVerboseMovieFrames)
                            self.vbVerboseMovieFrames = getframe(gcf);
                        else
                            self.vbVerboseMovieFrames(end+1) = getframe(gcf);
                        end
                    end
                    drawnow;
                end
                
            end
        end
    end
end
