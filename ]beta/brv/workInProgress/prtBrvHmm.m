classdef prtBrvHmm < prtBrv & prtBrvVb

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
    properties (SetAccess = private)

        name = ' Bayesian  Hidden Markov Model Random Variable';
        nameAbbreviation = 'BHMMRv';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties (Dependent) % Act as non-dependent
        transitionProbabilities
        initialProbabilities
        components
    end
    properties (Dependent, SetAccess='private')
        nComponents
    end
    
    properties (Hidden, SetAccess='private', GetAccess='private');
        internalTransitionProbabilities = prtBrvDiscrete;
        internalInitialProbabilities = prtBrvDiscrete;
        internalComponents = prtBrvMvn;
    end
    
    properties (Hidden)
        plotComponentProbabilityThreshold = 0.01;
    end
    
    methods
        function self = prtBrvHmm(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
            
            %obj.components = varargin{1}(:);
            %obj.initialProbabilities = prtBrvDiscrete(obj.nComponents);
            %obj.transitionProbabilities = repmat(prtBrvDiscrete(obj.nComponents),obj.nComponents,1);
            
        end
    end
    
    
    methods
        function self = conjugateUpdate(self, prior, x) %#ok<INUSL>
            warning('prt:prtBrvMixture:conjugateUpdate','Model is not fully conjugate resorting to vb');
            self = vb(self, x);
        end
        
        function self = estimateParameters(self, x)
            self = conjugateUpdate(self, self, x);
        end
        function y = predictivePdf(self, x)
            y = exp(predictiveLogPdf(self, x));
        end
        function y = predictiveLogPdf(self, x)
            y = conjugateVariationalAverageLogLikelihood(self,x);
        end
        
        function val = getNumDimensions(self)
            val = self.components(1).nDimensions;
        end
        
        function self = initialize(self, x)
            x = self.parseInputData(x);
            if iscell(x)
                x = x{1};
            end
            
            for iComp = 1:self.nComponents
                self.components(iComp) = self.components(iComp).initialize(x);
            end
        
            self.initialProbabilities = self.initialProbabilities.initialize(zeros(1,self.nComponents));
            self.transitionProbabilities = repmat(self.transitionProbabilities,self.nComponents,1);
            for iComp = 1:self.nComponents
                self.transitionProbabilities(iComp) = self.transitionProbabilities(iComp).initialize(zeros(1,self.nComponents));
            end
        end
    end
    
    methods (Hidden)
        function x = parseInputData(self,x) %#ok<MANU>
            if isnumeric(x) || islogical(x)
                x = {x};
                return
            elseif prtUtilIsSubClass(class(x),'prtDataSetBase')
                x = x.getObservations();
            elseif iscell(x)
                
            else 
                error('prt:prtBrvMixture:parseInputData','prtBrvMixture requires a prtDataSet or a numeric 2-D matrix');
            end
        end
    end    
    
    methods
        function obj = set.components(obj,components)
            assert( isa(components,'prtBrvMembershipModel'),'components must be a prtBrvObsModel')
            
            obj.internalComponents = components;
        end
        function val = get.components(obj)
            val = obj.internalComponents;
        end
        
        function obj = set.transitionProbabilities(obj,trans)
            %assert( isa(trans,'prtBrvDiscrete'),'transitionProbabilities must be an array of  prtBrvDiscrete''s')
            
            obj.internalTransitionProbabilities = trans;
        end
        function val = get.transitionProbabilities(obj)
            val = obj.internalTransitionProbabilities;
        end
        function obj = set.initialProbabilities(obj,init)
            %assert( isa(init,'prtBrvDiscrete'),'initialProbabilities must be a prtBrvDiscrete')
            
            obj.internalInitialProbabilities = init;
        end
        function val = get.initialProbabilities(obj)
            val = obj.internalInitialProbabilities;
        end
        
        
        function val = get.nComponents(obj)
            val = length(obj.components);
        end
    end
    
    methods
        


        function val = nDimensions(obj)
            val = obj.components(1).nDimensions;
        end
                
        function [obj, training] = vbBatch(obj, x)
            
            x = parseInputData(obj,x);
            
            % Initialize
            if obj.vbVerboseText
                fprintf('\n\nVB inference for a hidden Markov model with %d components\n', obj.nComponents)
                fprintf('\tInitializing VB HMM\n')
            end
            
            obj = obj.initialize(x);
            
            [obj, priorObj, training, x] = vbInitialize(obj, x);
            
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
                    [converged, err] = vbIsConverged(obj, priorObj, x, training);
                else
                    converged = false;
                    err = false;
                end
            
                % Plot
                if obj.vbVerbosePlot && (mod(iteration-1,obj.vbVerbosePlot) == 0)
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
        
        
        function eLogLikelihood = conjugateVariationalAverageLogLikelihood(obj,x)
            
            x = parseInputData(obj,x);
            
            if iscell(x)
                if length(x) > 1
                    lens = cellfun(@length,x);
                    training.startSamples = cat(1,1,cumsum(lens(1:(end-1)))+1);
                    x = cat(1,x{:});
                else
                    training.startSamples = 1;
                    x = x{1};
                end
            else
                training.startSamples = 1;
            end
            
            training.startTime = now;
            training.iterations.negativeFreeEnergy = [];
            training.iterations.eLogLikelihood = [];
            training.iterations.kld = [];
            
            [twiddle, training] = obj.vbE(obj, x, training); %#ok<ASGLU>
            
            %eLogLikelihood = sum(prtUtilSumExp(training.variationalLogLikelihoodBySample'));
            
            eLogLikelihood = zeros(length(training.startSamples),1);
            for iSeq = 1:length(eLogLikelihood)
                if iSeq == length(training.startSamples)
                    cEnd = size(x,1);
                else
                    cEnd = training.startSamples(iSeq+1)-1;
                end
                
                cLogLikes = training.variationalLogLikelihoodBySample(training.startSamples(iSeq):cEnd,:);
                eLogLikelihood(iSeq) = sum(prtUtilSumExp(cLogLikes'));
            end
            
            %eLogLikelihood = training.variationalLogLikelihoodBySample(training.startSamples,:)
        end
        
    end
    
    methods (Hidden)
        function [obj, priorObj, training, x] = vbInitialize(obj, x)
            
            training.randnState = randn('seed'); %#ok<RAND>
            training.randState = rand('seed'); %#ok<RAND>
            training.startTime = now;
            
            if iscell(x) 
                if length(x) > 1
                    lens = cellfun(@length,x);
                    training.startSamples = cat(1,1,cumsum(lens(1:(end-1)))+1);
                    x = cat(1,x{:});
                else
                    training.startSamples = 1;
                    x = x{1};
                end
            else
                training.startSamples = 1;
            end
            
            priorObj = obj;
            [training.phiMat, priorObj.components] = collectionInitialize(obj.components, obj.components, x);
            
            % Make up a xiMat. (Probability of transition to each state
            % from each state at each time.)
            % For initialization convenience we ignore multiple sequences
            % here. It shouldn't matter much. 
            training.xiMat = zeros([obj.nComponents, obj.nComponents, size(x,1)]);
            for iSamp = 1:size(x,1)-1
                training.xiMat(:,:,iSamp) = training.phiMat(iSamp,:)'*training.phiMat(iSamp+1,:);
                training.xiMat(:,:,iSamp) = bsxfun(@rdivide,training.xiMat(:,:,iSamp),sum(sum(training.xiMat(:,:,iSamp),2)));
            end
            training.xiMat(:,:,end) = training.phiMat(end,:)'*training.phiMat(end,:);
            training.xiMat(:,:,end) = bsxfun(@rdivide,training.xiMat(:,:,end),sum(sum(training.xiMat(:,:,end),2)));
            
            training.variationalLogLikelihoodBySample = -inf(size(x,1),obj.nComponents);
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
            
            for iSeq = 1:length(training.startSamples)
                if iSeq == length(training.startSamples)
                    cEnd = size(x,1);
                else
                    cEnd = training.startSamples(iSeq+1)-1;
                end
                
                % Some helpers for Forward Backwards
                logInitProbabilities = obj.initialProbabilities.expectedLogMean;
                
                logTransitionProbabilities = zeros(obj.nComponents);
                for iComp = 1:obj.nComponents
                    logTransitionProbabilities(iComp,:) = obj.transitionProbabilities(iComp).expectedLogMean;
                end
                
                % prtRvUtilLogForwardsBackwards
                [cLogAlpha, cLogBeta, cLogGamma, cLogXi] = prtRvUtilLogForwardsBackwards(logInitProbabilities, logTransitionProbabilities, training.variationalClusterLogLikelihoods(training.startSamples(iSeq):cEnd,:)');
                
                % Pack Up and ship out
                training.phiMat(training.startSamples(iSeq):cEnd,:) = exp(cLogGamma)';
                training.xiMat(:,:,training.startSamples(iSeq):cEnd) = exp(cLogXi);
                training.variationalLogLikelihoodBySample(training.startSamples(iSeq):cEnd,:) = cLogAlpha';
            end
        end
        
        function [obj, training] = vbM(obj, priorObj, x, training)
            
            % Iterate through each source and update using the current memberships
            for iSource = 1:obj.nComponents
                obj.components(iSource) = obj.components(iSource).weightedConjugateUpdate(priorObj.components(iSource), x, training.phiMat(:,iSource));
            end
    
            training.nSamplesPerCluster = sum(training.phiMat,1);
            training.nSamplesPerClusterInitial = sum(training.phiMat(training.startSamples,:),1);
            training.nSamplesPerTransition = sum(training.xiMat,3);
            
            % Update initial probabilities.
            obj.initialProbabilities = obj.initialProbabilities.conjugateUpdate(priorObj.initialProbabilities, training.nSamplesPerClusterInitial);
            
            % Update transition probabilities
            for iComp = 1:obj.nComponents
                obj.transitionProbabilities(iComp) = obj.transitionProbabilities(iComp).conjugateUpdate(priorObj.transitionProbabilities(iComp), training.nSamplesPerTransition(iComp,:));
            end
            
            %obj.mixingProportions = obj.mixingProportions.conjugateUpdate(priorObj.mixingProportions, training.nSamplesPerCluster);
            
        end
        
        function [nfe, eLogLikelihood, kld, kldDetails] = vbNfe(obj, priorObj, x, training) %#ok<INUSL>
            
            sourceKlds = zeros(obj.nComponents,1);
            for s = 1:obj.nComponents
                sourceKlds(s) = obj.components(s).conjugateKld(priorObj.components(s));
            end
            
            initProportionsKld = obj.initialProbabilities.conjugateKld(priorObj.initialProbabilities);
            
            transitionKlds = zeros(obj.nComponents,1);
            for s = 1:obj.nComponents
                transitionKlds(s) = obj.transitionProbabilities(s).conjugateKld(priorObj.transitionProbabilities(s)); 
            end
            transitionKldsSum = sum(transitionKlds);
            
            logTransitionProbabilities = zeros(obj.nComponents);
            for s = 1:obj.nComponents
                logTransitionProbabilities(s,:) = obj.transitionProbabilities(s).expectedLogMean;   
            end
            
            entropyTerm = training.phiMat.*log(training.phiMat);
            entropyTerm(isnan(entropyTerm)) = 0;
            entropyTerm = -sum(entropyTerm(:)) +  obj.initialProbabilities.expectedLogMean*sum(training.phiMat(training.startSamples,:),1)' + sum(sum(sum(training.xiMat,3).*logTransitionProbabilities));
            
            kldDetails.sources = sourceKlds(:);
            kldDetails.initialProbabilities = initProportionsKld;
            kldDetails.transitionProbabilities = transitionKlds;
            kldDetails.entropy = entropyTerm;
            
            kld = sum(sourceKlds) + initProportionsKld + transitionKldsSum + entropyTerm;
            
            eLogLikelihood = sum(prtUtilSumExp(training.variationalLogLikelihoodBySample([training.startSamples(2:end)-1; size(training.phiMat,1)],:)));
            
            nfe = eLogLikelihood - kld;
        end
        
        function vbIterationPlot(obj, priorObj, x, training) %#ok<INUSL>
            
            colors = prtPlotUtilClassColors(obj.nComponents);
            
            set(gcf,'color',[1 1 1]);
            
            initPis = obj.initialProbabilities.posteriorMeanStruct;
            initPis = initPis.probabilities(:)';
            
            transMat = zeros(obj.nComponents);
            for s = 1:obj.nComponents
                cStruct = obj.transitionProbabilities(s).posteriorMeanStruct;
                transMat(s,:) = cStruct.probabilities;
            end
            
            [sortedClusterPi, sortingInds] = sort(training.nSamplesPerCluster,'descend');
            sortedClusterPi = sortedClusterPi./sum(sortedClusterPi(:));
            initPis = initPis(sortingInds);
            transMat = transMat(sortingInds,sortingInds);
            
            colors = colors(sortingInds,:);
            
            % Initial Probs
            subplot(3,3,1)
            bar(cat(1,initPis,nan(1,obj.nComponents)));
            title('Initial State Prob.')
            xlabel('State')
            ylabel('\pi')
            ylim([0 1])
            xlim([0.5 1.5])
            set(gca,'XTick',[]);
            colormap(colors);
            
            % Transition Matrix
            subplot(3,3,2)
            cla(gca);
            for iSource = 1:size(transMat,1)
                for jSource = 1:size(transMat,2)
                    cSize = sqrt(transMat(jSource,iSource));
                    if cSize > 0
                        rectangle('Position',[iSource-cSize/2, jSource-cSize/2, cSize, cSize],'Curvature',[1 1],'FaceColor',colors(iSource,:),'EdgeColor',colors(iSource,:));
                    end
                end
            end
            set(gca,'YDir','Rev');
            title('Transition Prob.')
            xlabel('State')
            ylabel('State')
            xlim([0 size(transMat,1)+1])
            ylim([0 size(transMat,1)+1])

            % NFE
            subplot(3,3,3)
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

            % Components
            subplot(3,1,2)
            plotCollection(obj.components,colors);
            %componentsToPlot = sortedClusterPi > obj.plotComponentProbabilityThreshold;
            %if sum(componentsToPlot) > 0
            %    plot(obj.components(componentsToPlot),colors(componentsToPlot,:));
            %end
            
            randSelectPlot = true;
            nSamplesThreshold = 1000;
            
            if randSelectPlot
                cPlotInd = ceil(rand*length(training.startSamples));
                cStartSample = training.startSamples(cPlotInd);
                if cPlotInd == length(training.startSamples)
                    cEndSample = size(training.phiMat,1);
                else
                    cEndSample = training.startSamples(cPlotInd+1)-1;
                end
                
                cPhiMat = training.phiMat(cStartSample:cEndSample,sortingInds);
                
                
                if size(cPhiMat,1) > nSamplesThreshold
                    cPhiMat = imresize(cPhiMat,[nSamplesThreshold size(cPhiMat,2)]);
                end
            else
                cPhiMat = training.phiMat;
            end
            
            % Memberships
            subplot(3,1,3)
            area(cPhiMat,'edgecolor','none')
            % colormap set above in bar.
            ylim([0 1]);
            title('Cluster Memberships');
            
            drawnow;
        end
    end
    
    methods
        function x = posteriorMeanDraw(self, n, varargin)
            s = posteriorMeanStruct(self);
            

            
        end
        
        function s = posteriorMeanStruct(self)
            
            error('Not Finished Yet');
            
            %self.transitionProbabilities(1).
            
        end
    end
end
