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


classdef prtBrvVb
    
    methods (Abstract)
        [self, training] = vbBatch(self, x);
    end
    
    properties
        vbCheckConvergence = true; % Actually bother to calculate NFE
        vbConvergenceThreshold = 1e-6; % This is total change in NFE
        vbConvergenceDecreaseThreshold = 1e-3; % This is total change in NFE that will cause an exit
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
            
            signedPercentage = (F-pF);
            converged = signedPercentage < self.vbConvergenceThreshold;
    
            if self.vbVerboseText
                fprintf('\t\t\t Negative Free Energy: %0.2f, %+.2e Change',F,signedPercentage)
            end

            if signedPercentage < 0
                if self.vbVerboseText
                    fprintf('\tDecrease in negative free energy occured!!!')
                end
                converged = false;
                if abs(signedPercentage)>self.vbConvergenceDecreaseThreshold
                    if self.vbVerboseText
                        fprintf('\n\t\tDecrease in negative free energy is beyond numerical error expectations. Exiting.')
                    end
                    err = true;
                else
                    err = false;
                end
            else
                err = false;
            end
            
            if self.vbVerboseText
                fprintf('\n');
            end
            
        end
        function [converged, err] = vbIsConvergedAbs(self, priorSelf, x, training) %#ok<INUSL>
            F = training.negativeFreeEnergy;
            pF = training.previousNegativeFreeEnergy;
            
            signedPercentage = (F-pF);
            converged = abs(signedPercentage) < self.vbConvergenceThreshold;
    
            if self.vbVerboseText
                fprintf('\t\t\t Negative Free Energy: %0.2f, %+.2e Change\n',F,signedPercentage)
            end

            if signedPercentage < 0
                %if self.vbVerboseText
                %    fprintf('\t\tDecrease in negative free energy occured!!! Exiting.\n')
                %end
                %converged = false;
                err = true;
            else
                err = false;
            end
        end        
    end
end

