% PRTBRVVBONLINE - PRT BRV Variational Bayes Online Inference parameters
%   Contains properties and methods that are useful for prtBrv objects that
%   impliment online Variational Bayes methods. It abstracts that the
%   method vbOnlineUpdate and impliments vbOnline().
%
% This is currently in alpha and should not be used.

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
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
