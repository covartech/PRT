% PRTBRVIVB - PRT BRV Iterative Variational Bayes Object
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

classdef prtBrvIVb
    properties
        vbConvergenceThreshold = 1e-6; % This is a percentage of the total change in NFE
        vbMaxIterations = 1e3; % Maximum number of iterations
        vbVerboseText = false; % display text
        vbVerbosePlot = false; % plot after each iteration
        vbVerboseMovie = false; % make a movie with each frame of plotting
        vbVerboseMovieFrames = []; % Where we store the frames
        
        vbUseOnlineInsteadOfBatch = false; % If true you must also inherit from prtBrvVbOnline
    end
    
    methods (Hidden)
        function [converged, err] = vbCheckConvergence(obj, priorObj, x, training)
            F = training.negativeFreeEnergy;
            pF = training.previousNegativeFreeEnergy;
            
            signedPercentage(1) = (F-pF)./abs(mean([F pF])); %(1) removes mlint warning
            converged = signedPercentage < obj.vbConvergenceThreshold;
    
            if obj.vbVerboseText
                fprintf('\t\t\t Negative Free Energy: %0.2f, %+.2e Change\n',F,signedPercentage)
            end

            if signedPercentage < 0 && abs(F-pF)
                if obj.vbVerboseText
                    fprintf('\t\tDecrease in negative free energy occured!!! Exiting.\n')
                end
                converged = false;
                err = true;
            else
                err = false;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        function Obj = trainAction(Obj, DataSet)
            Obj = Obj.vb(DataSet.getObservations);
        end
        
        function DataSet = runAction(obj, DataSet)
            [obj, training] = vbE(obj, [], DataSet.getObservations(), []);
            DataSet = DataSet.setObservations(prtUtilSumExp(training.variationalLogLikelihoodBySample')');
        end
    end
    
    methods
        function [obj, training] = vb(obj, x)
            if obj.vbUseOnlineInsteadOfBatch
                [obj, training] = vbOnline(obj,x);
            else
                [obj, training] = vbBatch(obj,x);
            end
        end
    end
    methods (Abstract)
        [Obj, training] = vbBatch(Obj,x);
    end
end