% PRTBRVVB - PRT BRV Variational Bayes Object
%   Contains properties and methods for prtBrv objects that impliment
%   iterative variational Bayesian algorithms.
%
% Properties:
%   vbConvergenceThreshold = 1e-6; % This is a percentage of the total change in NFE
%   vbMaxIterations = 1e3; % Maximum number of iterations
%   vbVerboseText = false; % display text
%   vbVerbosePlot = false; % plot after each iteration
%   vbVerboseMovie = false; % make a movie with each frame of plotting
%   vbVerboseMovieFrames = []; % Where we store the frames
% Methods:
%   vbCheckConvergence - Used to check convergence at the end of each VB
%       iteration. Checks the percentage change in negative free energy.

classdef prtBrvVb
    
    methods (Abstract)
        [self, training] = vbBatch(self, x);
    end
    
    properties
        vbCheckConvergence = true; % Actually bother to calculate NFE
        vbConvergenceThreshold = 1e-6; % This is a percentage of the total change in NFE
        vbMaxIterations = 1e3; % Maximum number of iterations
        vbVerboseText = false; % display text
        vbVerbosePlot = false; % plot after each iteration
        vbVerboseMovie = false; % make a movie with each frame of plotting
        vbVerboseMovieFrames = []; % Where we store the frames
    end
    
    methods
        
        function [self, training] = vb(self, x)
            [self, training] = vbBatch(self, x);
        end
        
        function [converged, err] = vbIsConverged(self, priorSelf, x, training) %#ok<INUSL>
            F = training.negativeFreeEnergy;
            pF = training.previousNegativeFreeEnergy;
            
            signedPercentage(1) = (F-pF)./abs(mean([F pF])); %(1) removes mlint warning
            converged = signedPercentage < self.vbConvergenceThreshold;
    
            if self.vbVerboseText
                fprintf('\t\t\t Negative Free Energy: %0.2f, %+.2e Change\n',F,signedPercentage)
            end

            if signedPercentage < 0 && abs(F-pF)
                if self.vbVerboseText
                    fprintf('\t\tDecrease in negative free energy occured!!! Exiting.\n')
                end
                converged = false;
                err = true;
            else
                err = false;
            end
        end
    end
end

