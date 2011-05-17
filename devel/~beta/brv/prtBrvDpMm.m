classdef prtBrvDpMm < prtBrvMm
    properties
        mixingProportions
        components
    end
    properties (Dependent, SetAccess='private')
        nComponents
    end
    methods
        
        function obj = prtBrvDpMm(varargin)
            if nargin < 1
                return
            end
            
            obj.components = varargin{1}(:);
            obj.mixingProportions = prtBrvDiscreteStickBreaking(obj.nComponents);
        end
        
        function val = nDimensions(obj)
            val = obj.components(1).nDimensions;
        end
        
        function val = get.nComponents(obj)
            val = length(obj.components);
        end
        
        function [obj, training] = vb(obj, x)
            
            % Initialize
            if obj.vbVerboseText
                fprintf('\n\nVB inference for a mixture model with %d components\n', obj.nComponents)
                fprintf('\tInitializing VB Mixture Model\n')
            end
            [obj, priorObj, training] = vbInitialize(obj, x);
            
            if obj.vbVerboseText
                fprintf('\tIterating VB Updates\n')
            end
            
            for iteration = 1:obj.vbMaxIterations
                
                % VBM Step
                [obj, training] = vbM(obj, priorObj, x, training);
                
                % Initial VBE Step
                [obj, training] = vbE(obj, priorObj, x, training);            
            
                % Calculate NFE
                [nfe, eLogLikelihood, kld, kldDetails] = vbNfe(obj, priorObj, x, training);
                
                % Update training information
                training.previousNegativeFreeEnergy = training.negativeFreeEnergy;
                training.negativeFreeEnergy = nfe;
                training.iterations.negativeFreeEnergy(iteration) = nfe;
                training.iterations.eLogLikelihood(iteration) = eLogLikelihood;
                training.iterations.kld(iteration) = kld;
                training.iterations.kldDetails(iteration) = kldDetails;
                training.nIterations = iteration;
                
                % Check covergence
                if iteration > 1
                    [converged, err] = vbCheckConvergence(obj, priorObj, x, training);
                else
                    converged = false;
                    err = false;
                end
            
                % Plot
                if mod(iteration-1,obj.vbVerbosePlot) == 0
                    vbIterationPlot(obj, priorObj, x, training);
                    
                    if obj.vbVerboseMovie
                        if isempty(obj.vbVerboseMovieFrames)
                            obj.vbVerboseMovieFrames = getframe(gcf);
                        else
                            obj.vbVerboseMovieFrames(end+1) = getframe(gcf);
                        end
                    end
                end
                
                if converged
                    if obj.vbVerboseText
                        fprintf('\tConvergence reached. Change in negative free energy below threhsold.\n')
                    end
                    break
                end
                
                if err
                    break
                end
                
            end
            
            if ~converged && ~err && obj.vbVerboseText
                fprintf('\nLearning did not complete in the allotted number of iterations.\n\n')
            end
            
            training.stopTime = now;
        end
        
        function [obj, training] = vbOnlineUpdate(obj, priorObj, x, training, prevObj)
            
            if nargin < 5 || isempty(prevObj)
                prevObj = obj;
            end
            
            if nargin < 4 || isempty(training)
                training.startTime = now;
                training.iterations.negativeFreeEnergy = [];
                training.iterations.eLogLikelihood = [];
                training.iterations.kld = [];                
                [obj, training] = obj.vbE(priorObj, x, training);
            end
            
            obj.nSamples = obj.nSamples + size(x,1);
            obj.vbOnlineT = obj.vbOnlineT + 1;
            
            % Update components
            for s = 1:obj.nComponents
                obj.components(s) = obj.components(s).vbOnlineWeightedUpdate(priorObj.components(s), x, training.phiMat(:,s), obj.vbOnlineLambda, obj.vbOnlineD, prevObj.components(s));
            end
            obj.mixingProportions = obj.mixingProportions.vbOnlineWeightedUpdate(priorObj.mixingProportions, training.phiMat, [], obj.vbOnlineLambda, obj.vbOnlineD, prevObj.mixingProportions);
            
        end
        
        function [obj, training] = vbNonStationaryUpdate(obj, priorObj, x, training, prevObj)
            
            if nargin < 5 || isempty(prevObj)
                prevObj = obj;
            end
            
            if nargin < 4 || isempty(training)
                training.startTime = now;
                training.iterations.negativeFreeEnergy = [];
                training.iterations.eLogLikelihood = [];
                training.iterations.kld = [];                
                [obj, training] = obj.vbE(priorObj, x, training);
            end
            
            obj.nSamples = obj.nSamples + size(x,1);
            obj.vbOnlineT = obj.nSamples;
                        
            % Update components
            for s = 1:obj.nComponents
                cBaseDensity = prevObj.components(s).weightedConjugateUpdate(prevObj.components(s),x,training.phiMat(:,s));
                obj.components(s) = obj.components(s).vbOnlineWeightedUpdate(priorObj.components(s), x, training.phiMat(:,s), obj.vbOnlineLambda, obj.vbOnlineD, cBaseDensity);
            end
            cBaseDensity = prevObj.mixingProportions.weightedConjugateUpdate(prevObj.mixingProportions,training.phiMat,[]);
            obj.mixingProportions = obj.mixingProportions.vbOnlineWeightedUpdate(priorObj.mixingProportions, training.phiMat, [], obj.vbOnlineLambda, obj.vbOnlineD, cBaseDensity);

        end        
    end
    methods (Hidden)
        function [obj, priorObj, training] = vbInitialize(obj, x)
            
            training.randnState = randn('seed'); %#ok<RAND>
            training.randState = rand('seed'); %#ok<RAND>
            training.startTime = now;
            
            priorObj = obj;
            [training.phiMat, priorObj.components] = mixtureInitialize(obj.components, obj.components, x);
            
            obj.nSamples = obj.nSamples + size(x,1);
            
            training.variationalClusterLogLikelihoods = zeros(size(x,1),obj.nComponents);
            training.negativeFreeEnergy = 0;
            training.previousNegativeFreeEnergy = nan;
            training.iterations.negativeFreeEnergy = [];
            training.iterations.eLogLikelihood = [];
            training.iterations.kld = [];
            training.nIterations = 0;
        end
        
        function [obj, training] = vbE(obj, priorObj, x, training) %#ok<INUSL>
            % Calculate the variational Log Likelihoods of each cluster
            for iSource = 1:obj.nComponents
                training.variationalClusterLogLikelihoods(:,iSource) = ...
                    obj.components(iSource).conjugateVariationalAverageLogLikelihood(x);
            end
            
            sourceVariationalLogLikelihoods = obj.mixingProportions.expectedLogMean;
            
            training.variationalLogLikelihoodBySample = bsxfun(@plus,training.variationalClusterLogLikelihoods, sourceVariationalLogLikelihoods);
            training.phiMat = exp(bsxfun(@minus, training.variationalLogLikelihoodBySample, prtUtilSumExp(training.variationalLogLikelihoodBySample')'));
            
        end
        
        function [obj, training] = vbM(obj, priorObj, x, training)
            
            % Iterate through each source and update using the current memberships
            for iSource = 1:obj.nComponents
                obj.components(iSource) = obj.components(iSource).weightedConjugateUpdate(priorObj.components(iSource), x, training.phiMat(:,iSource));
            end
    
            % Updated mixingProportions
            obj.mixingProportions = obj.mixingProportions.conjugateUpdate(priorObj.mixingProportions, sum(training.phiMat,1));
            
        end
        
        function [nfe, eLogLikelihood, kld, kldDetails] = vbNfe(obj, priorObj, x, training) %#ok<INUSL>
            
            sourceKlds = zeros(obj.nComponents,1);
            for s = 1:obj.nComponents
                sourceKlds(s) = obj.components(s).conjugateKld(priorObj.components(s));
            end
            mixingProportionsKld = obj.mixingProportions.conjugateKld(priorObj.mixingProportions);
            
            kldDetails.sources = sourceKlds(:);
            kldDetails.mixingProportions = mixingProportionsKld;
            
            kld = sum(sourceKlds) + mixingProportionsKld;
            
            eLogLikelihood = sum(prtUtilSumExp(training.variationalLogLikelihoodBySample'));
            
            nfe = eLogLikelihood - kld;
        end
        
        function vbIterationPlot(obj, priorObj, x, training) %#ok<INUSL>
            
            colors = prtPlotUtilClassColors(obj.nComponents);
            
            set(gcf,'color',[1 1 1]);
            
            subplot(3,2,1)
            mixingPropPostMean = obj.mixingProportions.posteriorMeanStruct;
            mixingPropPostMean = mixingPropPostMean.probabilities;
            bar([mixingPropPostMean(:)'; nan(1,length(mixingPropPostMean(:)))])
            colormap(colors);
            ylim([0 1])
            xlim([0.5 1.5])
            set(gca,'XTick',[]);
            title('Source Probabilities');
            
            subplot(3,2,2)
            if ~isempty(training.iterations.negativeFreeEnergy)
                plot(training.iterations.negativeFreeEnergy,'k-')
                hold on
                plot(training.iterations.negativeFreeEnergy,'rx','markerSize',8)
                hold off
                xlim([0.5 length(training.iterations.negativeFreeEnergy)+0.5]);
            else
                plot(nan,nan)
                axis([0.5 1.5 0 1])
            end
            title('Convergence Criterion')
            xlabel('Iteration')

            subplot(3,1,2)
            plot(obj.components);
            
            subplot(3,1,3)
            if obj.nDimensions < 4
                [~, cY] = max(training.phiMat,[],2);
                allHandles = plot(prtDataSetClass(x,cY));
                
                uY = unique(cY);
                for s = 1:length(uY)
                    cColor = colors(uY(s),:);
                    set(allHandles(s),'MarkerFaceColor',cColor,'MarkerEdgeColor',prtPlotUtilLightenColors(cColor));
                end
                legend('off');
            else
                area(training.phiMat,'edgecolor','none')
                colormap(colors)
                ylim([0 1]);
                title('Cluster Memberships');
            end
            
            drawnow;
        end
    end
end
        