classdef prtBrvVb
    properties
        vbConvergenceThreshold = 1e-6; % This is a percentage of the total change in NFE
        vbMaxIterations = 1e3; % Maximum number of iterations
        vbVerboseText = false; % display text
        vbVerbosePlot = false;
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
                %err = true;
                err = false;
            else
                err = false;
            end
        end
    end
end