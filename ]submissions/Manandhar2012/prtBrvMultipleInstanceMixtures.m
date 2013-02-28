classdef prtBrvMultipleInstanceMixtures < prtBrv & prtBrvVbOnline

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


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties required by prtAction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        name = 'Multiple Instance Mixture Bayesian Random Variable';
        nameAbbreviation = 'NPBMIL';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrv
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    methods
        function self = estimateParameters(self, x)
            self = conjugateUpdate(self, self, x);
        end
        
        function y = predictivePdf(self, x)
            y = exp(predictiveLogPdf(self, x));
        end
        function y = predictiveLogPdf(self, x)
            %%%% FIXME
            % The true predictive is not finished yet. This is an
            % approximation
            
            y = conjugateVariationalAverageLogLikelihood(self, x);    
        end
        
        
        function val = getNumDimensions(self)
            val = self.components(1).nDimensions;
        end
        
        function self = initialize(self, x)
            %x = self.parseInputData(x);
            
            xData = cat(1,x.X.data);
            for iComp = 1:self.nComponents
                self.components(iComp) = self.components(iComp).initialize(xData);
            end
            self.mixing = self.mixing.initialize(zeros(1,self.nComponents));
        end
        
%         % Optional methods
%         %------------------------------------------------------------------
%         function val = plotLimits(self)
%             
%             
%             
%             allVal = zeros(self.nComponents, self.components(1).plotLimits);
%             for s = 1:self.nComponents
%                 allVal(s,:) = obj.components(s).plotLimits();
%             end
%             val = zeros(1,size(allVal,2));
%             for iDim = 1:size(allVal,2)
%                 if mod(iDim,2)
%                     val(iDim) = min(allVal(:,iDim));
%                 else
%                     val(iDim) = max(allVal(:,iDim));
%                 end
%             end
%         end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVb
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function [self, training, prior] = vbBatch(self, x)
            
            self = initialize(self,x);
            
            % Initialize
            if self.vbVerboseText
                fprintf('\n\nVB inference for NPBMIL\n')
                fprintf('\tInitializing \n')
            end
            
            [self, prior, training] = vbInitialize(self, x);
            
            [self, training, converged, err] = vbBatchIterate(self, prior, x, training);
            
            if self.vbCheckConvergence && self.vbVerboseText
                fprintf('\nAll VB iterations complete.\n\n')
            end
            if self.vbCheckConvergence && ~converged && ~err && self.vbVerboseText
                fprintf('\nLearning did not complete in the allotted number of iterations.\n\n')
            end
            
            training.endTime = now;
        end
        
        function [self, training, converged, err] = vbBatchIterate(self, prior, x, training)
            if self.vbVerboseText
                fprintf('\tIterating VB Updates\n')
            end
            
            for iteration = 1:self.vbMaxIterations
                
                % VBM Step
                [self, training] = vbM(self, prior, x, training);
                
                % Initial VBE Step
                [self, training] = vbE(self, prior, x, training);            
            
                % Calculate NFE
                [nfe, eLogLikelihood, kld] = vbNfe(self, prior, x, training);
                
                % Update training information
                training.previousNegativeFreeEnergy = training.negativeFreeEnergy;
                training.negativeFreeEnergy = nfe;
                training.iterations.negativeFreeEnergy(iteration) = nfe;
                training.iterations.eLogLikelihood(iteration) = eLogLikelihood;
                training.iterations.kld(iteration) = kld;
                training.nIterations = iteration;
                
                % Check covergence
                
                if self.vbCheckConvergence && iteration > 1
                    [converged, err] = vbIsConvergedAbs(self, prior, x, training);
                else
                    converged = false;
                    err = false;
                end
                
                % Plot
                if self.vbVerbosePlot && (mod(iteration-1,self.vbVerbosePlot) == 0)
                    vbIterationPlot(self, prior, x, training);
                    
                    if self.vbVerboseMovie
                        if isempty(self.vbVerboseMovieFrames)
                            self.vbVerboseMovieFrames = getframe(gcf);
                        else
                            self.vbVerboseMovieFrames(end+1) = getframe(gcf);
                        end
                    end
                end
                
                if converged
                    if self.vbVerboseText
                        fprintf('\tConvergence reached. Change in negative free energy below threhsold.\n')
                    end
                    break
                end
                
                %if err
                %    break
                %end
                
            end
        end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % We don't actualy inherit from prtBrvVbMembershipModel yet so we don't
    % actually have to implement this but we do
    methods
        function y = conjugateVariationalAverageLogLikelihood(obj,x)
            
            training = prtBrvMixtureVbTraining;
            
            [twiddle, training] = obj.vbE(obj, x, training); %#ok<ASGLU>
            y = sum(prtUtilSumExp(training.variationalLogLikelihoodBySample'));
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbOnline
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function [obj, priorObj, training] = vbOnlineInitialize(obj,x)
            
            training = prtBrvMixtureVbTraining;
            
            obj = initialize(obj, x);
            
            priorObj = obj;
            
            % Intialize mixing
            obj.mixing = obj.mixing.vbOnlineInitialize([]);
            
            % Iterate through each source and update using the current memberships
            for iSource = 1:obj.nComponents
                obj.components(iSource) = obj.components(iSource).vbOnlineInitialize(x);
            end
            
        end
        
        function [obj, training] = vbOnlineUpdate(obj, priorObj, x, training, prevObj, learningRate, D)
            
            if nargin < 5 || isempty(prevObj)
                prevObj = obj;
            end
            
            if nargin < 4 || isempty(training)
                training = prtBrvMixtureVbTraining;
                training.iterations.negativeFreeEnergy = [];
                training.iterations.eLogLikelihood = [];
                training.iterations.kld = [];
                [obj, training] = obj.vbE(priorObj, x, training);
            end
            
            % Update components
            for s = 1:obj.nComponents
                obj.components(s) = obj.components(s).vbOnlineWeightedUpdate(priorObj.components(s), x, training.componentMemberships(:,s), learningRate, D, prevObj.components(s));
            end
            obj.mixing = obj.mixing.vbOnlineWeightedUpdate(priorObj.mixing, training.componentMemberships, [], learningRate, D, prevObj.mixing);
            
            training.nSamplesPerComponent = sum(training.componentMemberships,1);
            
            %[nfe, eLogLikelihood, kld, kldDetails] = vbNfe(obj, priorObj, x, training); %#ok<NASGU,ASGLU>
            %training.negativeFreeEnergy = -kld;
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties and Methods for prtBrvMixture use
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function self = prtBrvMultipleInstanceMixtures(varargin)
            if nargin < 1
                return
            end
            
            self = constructorInputParse(self,varargin{:});
        end
        
        % This could potentially be abstracted by prtBrvVbOnlineNonStationary but
        % that does not exist yet.
        function [obj, training] = vbNonStationaryUpdate(obj, priorObj, x, training, prevObj)
            
            if nargin < 5 || isempty(prevObj)
                prevObj = obj;
            end
            
            if nargin < 4 || isempty(training)
                training = prtBrvMixtureVbTraining;
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
            cBaseDensity = prevObj.mixing.weightedConjugateUpdate(prevObj.mixing,training.phiMat,[]);
            obj.mixing = obj.mixing.vbOnlineWeightedUpdate(priorObj.mixing, training.phiMat, [], obj.vbOnlineLambda, obj.vbOnlineD, cBaseDensity);

        end      
    end
    
    % Some properties (some extra hidden private properties to avoid
    % property access issues  when loading and saving
    %----------------------------------------------------------------------
    properties
        forceOnePositiveInstancePerPositiveBag = true;
    end
    properties (Dependent) 
        mixing
        components
    end
    properties (Hidden, SetAccess='private', GetAccess='private');
        internalMixing = prtBrvDiscrete;
        internalComponents = repmat(prtBrvMixture('components',repmat(prtBrvMvn,2,1)),2,1);
    end
    properties (Dependent, SetAccess='private')
        nComponents
    end
    properties (Hidden)
        plotComponentProbabilityThreshold = 0.01;
    end
    
    % Set and get methods for weird properties
    %----------------------------------------------------------------------
    methods
        function obj = set.components(obj,components)
            assert( isa(components,'prtBrvMembershipModel'),'components must be a prtBrvMembershipModel')
            
            obj.internalComponents = components;
        end
        
        function val = get.components(obj)
            val = obj.internalComponents;
        end
        
        function obj = set.mixing(obj,mix)
            obj.internalMixing = mix;
        end
        
        function val = get.mixing(obj)
            val = obj.internalMixing;
        end
        
        function val = get.nComponents(obj)
            val = obj.getNumComponents();
        end
        
        function val = getNumComponents(self)
            val = length(self.components);
        end
    end
    
    
    % Methods for doing VB (called by batch VB above)
    %----------------------------------------------------------------------
    methods
        function [obj, priorObj, training] = vbInitialize(obj, x)
            
            training = prtBrvMultipleInstanceMixturesVbTraining;
                    
            training.bagInds = x.bagInds;
            training.clusterIsCertainH0 = x.expandedTargets==0;
            
            priorObj = obj;
            
            switch lower(obj.vbInitializationMethod)
                case 'h0mixture'
                    % Intialize H0 mixture first then use likelihoods to
                    % select H1 instances
                    
                    if obj.nComponents > 2
                        error('This initialization method only works for binary classificaiton');
                    end
                    
                    isH0 = training.clusterIsCertainH0;
                    isH0 = logical(isH0(:,1));
                    
                    training.componentMemberships = zeros(x.nObservations,obj.nComponents);
                    training.componentMemberships(isH0,1) = 1;
                    
                    xData = x.expandedData;
                    
                    cX = xData(isH0,:);
                    [obj.components(1), priorObj.components(1), training.componentTraining(1)] = vbInitialize(obj.components(1), cX);
                    nH0IntializationIterations = 20;
                    [obj.components(1), training.componentTraining(1)] = vbM(obj.components(1), priorObj.components(1), cX, training.componentTraining(1));
                    for iter = 1:nH0IntializationIterations
                        [obj.components(1), training.componentTraining(1)] = vbE(obj.components(1), priorObj.components(1), cX, training.componentTraining(1));
                        [obj.components(1), training.componentTraining(1)] = vbM(obj.components(1), priorObj.components(1), cX, training.componentTraining(1));
                    end
                    % Now rerun E step on all data to get all memberships
                    [~, training.componentTraining(1)] = vbE(obj.components(1), priorObj.components(1), xData, training.componentTraining(1));
                    
                    % vbIterationPlot(obj.components(1),priorObj.components(1), xData, training.componentTraining(1));
                    
                    % Select h1 instances
                    % We select the one with the minimum h0 likelihood in eachbag
                    % and anything with a likelihood less than the minumum seen in
                    % the h0 bags
                    h0LogLikelihoods = prtUtilSumExp(training.componentTraining(1).variationalClusterLogLikelihoods')';
                    isH1 = false(size(isH0));
                    bags = training.bagInds;
                    for iBag = 1:x.nBags
                        cInds = find(bags==iBag);
                        [~, cBestH1Ind] = min(h0LogLikelihoods(cInds));
                        isH1(cInds(cBestH1Ind)) = true;
                    end
                    
                    isH1 = ~isH0 & (isH1 | (h0LogLikelihoods < min(h0LogLikelihoods(isH0))));
                    
                    training.componentMemberships(~isH0 & isH1, 2) = 1;
                    training.componentMemberships(~isH0 & ~isH1, 1) = 1;
                    
                    
                    cX = xData(training.componentMemberships(:,2)>0.5,:);
                    [obj.components(2), priorObj.components(2), training.componentTraining(2)] = vbInitialize(obj.components(2), cX);
                    nH1IntializationIterations = 1;
                    [obj.components(2), training.componentTraining(2)] = vbM(obj.components(2), priorObj.components(2), cX, training.componentTraining(2));
                    for iter = 1:nH1IntializationIterations
                        [obj.components(2), training.componentTraining(2)] = vbE(obj.components(2), priorObj.components(2), cX, training.componentTraining(2));
                        [obj.components(2), training.componentTraining(2)] = vbM(obj.components(2), priorObj.components(2), cX, training.componentTraining(2));
                    end
                    % Now rerun E step on all data to get memberships
                    [obj.components(2), training.componentTraining(2)] = vbE(obj.components(2), priorObj.components(2), xData, training.componentTraining(2));
                    
                case 'random'
                    
                    xData = x.expandedData();
                    
                    [training.componentMemberships, priorObj.components] = collectionInitialize(obj.components, obj.components, xData);
                    
                    % Enforce H0 Bags to only have negative instances.
                    training.componentMemberships(training.clusterIsCertainH0,1) = 1;
                    training.componentMemberships(training.clusterIsCertainH0,2) = 0;
                    
                    for iComp = 1:obj.nComponents
                        cX = xData(training.componentMemberships(:,iComp) > 0.1,:);
                        [obj.components(iComp), priorObj.components(iComp), training.componentTraining(iComp)] = vbInitialize(obj.components(iComp), cX);
                        
                        cObjMaximized = vbM(obj.components(iComp), priorObj.components(iComp), cX,  training.componentTraining(iComp));
                        
                        [~, training.componentTraining(iComp)] = vbE(cObjMaximized, priorObj.components(iComp), xData, training.componentTraining(iComp));
                    end

                otherwise
                    error('vbInitializationMethod must be either h0Mixture or random');
            end
            

            training.variationalLogLikelihoodBySample = -inf(size(x,1),obj.nComponents);
        end
        
        function [obj, training] = vbE(obj, priorObj, x, training)
            
            xData = x.expandedData();     
            training.variationalClusterLogLikelihoods = zeros(size(xData,1),obj.nComponents);
            for iSource = 1:obj.nComponents
                [obj.components(iSource), training.componentTraining(iSource)] = vbE(obj.components(iSource), priorObj.components(iSource), xData, training.componentTraining(iSource));
                
                training.variationalClusterLogLikelihoods(:,iSource) = prtUtilSumExp(training.componentTraining(iSource).variationalLogLikelihoodBySample')';
                
                % We need to fix the VBE step to account for the membership
                % weights within this mixture
                
                %training.componentTraining(iSource).variationalClusterLogLikelihoods = bsxfun(@times, training.componentMemberships(:,iSource), training.componentTraining(iSource).variationalClusterLogLikelihoods);
                %logPi = obj.components(iSource).mixing.expectedLogMean;
                %training.componentTraining(iSource).variationalLogLikelihoodBySample = bsxfun(@plus, training.componentTraining(iSource).variationalClusterLogLikelihoods, logPi(:)');
                %training.componentTraining(iSource).componentMemberships = exp(bsxfun(@minus, training.componentTraining(iSource).variationalLogLikelihoodBySample, prtUtilSumExp(training.componentTraining(iSource).variationalLogLikelihoodBySample')'));
                
                logPi = obj.components(iSource).mixing.expectedLogMean;
                weightedClusterLogLikelihoods = bsxfun(@plus, bsxfun(@times, training.componentMemberships(:,iSource), training.componentTraining(iSource).variationalClusterLogLikelihoods), logPi(:)');
                training.componentTraining(iSource).componentMemberships = exp(bsxfun(@minus, weightedClusterLogLikelihoods, prtUtilSumExp(weightedClusterLogLikelihoods')'));
                
            end
            
            logEta = obj.mixing.expectedLogMean;
            training.variationalLogLikelihoodBySample = bsxfun(@plus,training.variationalClusterLogLikelihoods, logEta(:)');
            
            training.componentMemberships = exp(bsxfun(@minus, training.variationalLogLikelihoodBySample, prtUtilSumExp(training.variationalLogLikelihoodBySample')'));
            
            training.componentMemberships(training.clusterIsCertainH0,:) = 0;
            training.componentMemberships(training.clusterIsCertainH0,1) = 1;
            
            if obj.forceOnePositiveInstancePerPositiveBag && ~isempty(training.bagInds) && x.isLabeled
                % Hack!!!
                % Trying to force one instance from each bag into the positive
                % mixture.
                for iBag = 1:max(training.bagInds)
                    if ~x.Y(iBag)
                        continue
                    end
                    isThisBag = training.bagInds==iBag;
                    isThisBagInds = find(isThisBag);
                    
                    % Most H1 Like
                    cLikes = training.variationalClusterLogLikelihoods(isThisBag,2);
                    [~, bestInd] = max(cLikes);
                    training.componentMemberships(isThisBagInds(bestInd),:)  = [0 1];
                end
            end
            
        end
        
        function [obj, training] = vbM(obj, priorObj, x, training)
            
            % Iterate through each source and update using the current memberships
            xData = x.expandedData;
            for iSource = 1:obj.nComponents
                obj.components(iSource) = obj.components(iSource).weightedConjugateUpdate(priorObj.components(iSource), xData, training.componentMemberships(:,iSource), training.componentTraining(iSource));
            end
    
            training.nSamplesPerComponentH1 = sum(training.componentMemberships(~training.clusterIsCertainH0,:),1);
            training.nSamplesPerComponent = sum(training.componentMemberships,1);
            
            % Updated mixing
            obj.mixing = obj.mixing.conjugateUpdate(priorObj.mixing, training.nSamplesPerComponentH1);
            
        end
        
        function [nfe, eLogLikelihood, kld, kldDetails] = vbNfe(obj, priorObj, x, training) %#ok<INUSL>
            
            vbNfeIncludeMemerships = true;
            
            sourceKlds = zeros(obj.nComponents,1);
            
            xData = x.expandedData;
            componentMembershipKlds = zeros(size(xData,1),obj.nComponents);
            for s = 1:obj.nComponents
                [~, ~, sourceKlds(s), sourceKldComponents(s,1)] = vbNfe(obj.components(s), priorObj.components(s), xData, training.componentTraining(s)); %#ok<AGROW>
                
                if vbNfeIncludeMemerships
                    % The mixture NFE code lumps in the membershipKlds with the other KLDs
                    % We don't want this so we subtract it out. We will put it
                    % back in using the proper weighting
                    sourceKlds(s) = sourceKlds(s)-sum(sourceKldComponents(s).memberships);
                    
                    cJointMembership = bsxfun(@times, training.componentMemberships(:,s), training.componentTraining(s).componentMemberships);
                    
                    cEntropyTerm = cJointMembership.*log(training.componentTraining(s).componentMemberships);
                    cEntropyTerm(isnan(cEntropyTerm)) = 0;
                    logPi = obj.components(s).mixing.expectedLogMean;
                    
                    componentMembershipKlds(:,s) = sum(cEntropyTerm,2)-sum(bsxfun(@times, cJointMembership, logPi(:)'),2);
                end
            end
            
            mixingKld = obj.mixing.conjugateKld(priorObj.mixing);
            
            notH0Inds = ~training.clusterIsCertainH0;
            entropyTerm = training.componentMemberships(notH0Inds,:).*log(training.componentMemberships(notH0Inds,:));
            entropyTerm(isnan(entropyTerm)) = 0;
            logPi = obj.mixing.expectedLogMean;
            membershipKlds = sum(entropyTerm,2)-sum(bsxfun(@times, training.componentMemberships(notH0Inds,:),logPi(:)'),2);
            
            kldDetails.sources = sourceKlds(:);
            kldDetails.mixing = mixingKld;
            kldDetails.memberships = membershipKlds(:);
            
            if vbNfeIncludeMemerships
                kld = sum(sourceKlds) + mixingKld + sum(membershipKlds) + sum(componentMembershipKlds(:));
                eLogLikelihoodComponents = zeros(size(training.clusterIsCertainH0,1),obj.nComponents);
                for iComp = 1:obj.nComponents
                    cCompTrain = training.componentTraining(iComp);
                    eLogLikelihoodComponents(:,iComp) = sum(cCompTrain.variationalClusterLogLikelihoods.*cCompTrain.componentMemberships,2);
                end
                eLogLikelihood = sum(sum(training.componentMemberships.*eLogLikelihoodComponents,2));
            else
                isH0 = training.clusterIsCertainH0;
                eLogLikelihood = sum(cat(1,training.variationalClusterLogLikelihoods(isH0,1), prtUtilSumExp(training.variationalLogLikelihoodBySample(~isH0,:)')'));
                kld = sum(sourceKlds) + mixingKld;
            end
            
            nfe = eLogLikelihood - kld;
        end
        
        function vbIterationPlot(obj, priorObj, x, training) %#ok<INUSL>
            
            colors = prtPlotUtilClassColors(obj.nComponents);
            
            set(gcf,'color',[1 1 1]);
            
            subplot(3,2,1)
            mixingPropPostMean = obj.mixing.posteriorMeanStruct;
            mixingPropPostMean = mixingPropPostMean.probabilities;
            
            [mixingPropPostMeanSorted, sortingInds] = sort(mixingPropPostMean,'descend');
            
            bar([mixingPropPostMeanSorted(:)'; nan(1,length(mixingPropPostMean(:)))])
            colormap(colors(sortingInds,:));
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
            plot(nan,nan);
            componentsToPlot = mixingPropPostMean > obj.plotComponentProbabilityThreshold;
            if sum(componentsToPlot) > 0
                plotCollection(obj.components(componentsToPlot),colors(componentsToPlot,:));
            end
               
            subplot(3,1,3)
            if obj.nDimensions < 4
                [~, cY] = max(training.componentMemberships,[],2);
                allHandles = plot(prtDataSetClass(x.expandedData,cY));
                
                uY = unique(cY);
                for s = 1:length(uY)
                    cColor = colors(uY(s),:);
                    set(allHandles(s),'MarkerFaceColor',cColor,'MarkerEdgeColor',prtPlotUtilLightenColors(cColor));
                end
                legend('off');
            
            else
                area(training.componentMemberships(:,sortingInds),'edgecolor','none')
                % colormap set above in bar.
                ylim([0 1]);
                title('Cluster Memberships');
            end
            
            drawnow;
        end
        
        function out = approximateBagLikelihoodRatio(self, x)
            training = prtBrvMultipleInstanceMixturesVbTraining;
            training.componentTraining = repmat(training.componentTraining,self.nComponents,1);
            
            [~, training] = vbE(self, self, x, training);
            
            h1Likelihood = prtUtilSumExp(training.variationalLogLikelihoodBySample')';
            h0Likelihood = training.variationalClusterLogLikelihoods(:,1);
            
            bagInds = x.bagInds;
            out = accumarray(bagInds, h1Likelihood)-accumarray(bagInds,h0Likelihood);
        end
        
        function out = approximateBagHypothesisProbablitiy(self, x)
            % Calculates the probability that all instances in a bag are
            % negative instances.
            
            xExpanded = x.expandedData;
            logLikelilihoods = zeros(size(xExpanded,1),length(self.components));
            for iComp = 1:length(self.components)
                logLikelilihoods(:,iComp) = predictiveLogPdf(self.components(iComp), xExpanded);
            end
            
            h0Likelihood = logLikelilihoods(:,1);
            
            h0LogProbability = h0Likelihood-prtUtilSumExp(logLikelilihoods')';
            
            bagInds = x.bagInds;
            h0LogProbabilityBag = accumarray(bagInds, h0LogProbability);
            
            out = 1-exp(h0LogProbabilityBag);
        end
    end
    
    methods (Hidden)
        function x = parseInputData(self,x) %#ok<MANU>
            if isnumeric(x) || islogical(x)
                return
            elseif prtUtilIsSubClass(class(x),'prtDataSetBase')
                x = x.getObservations();
            else 
                error('prt:prtBrvMixture:parseInputData','prtBrvMixture requires a prtDataSet or a numeric 2-D matrix');
            end
        end
        
        function self = vbBatchMultiWarmUp(self,ds,nWarmUps,nWarmUpIterations)
            
            if nargin < 3 || isempty(nWarmUps)
                nWarmUps = 5;
            end
            
            if nargin < 4 || isempty(nWarmUpIterations)
                nWarmUpIterations = 5;
            end
            
            if self.vbVerboseText
                fprintf('\n\nVB inference for NPBMIL\n')
                fprintf('\tInitializing using %d trials with %d iterations each\n', nWarmUps, nWarmUpIterations)
            end
            
            trainings = cell(nWarmUps,1);
            priors = cell(nWarmUps, 1);
            
            selfInit = self;
            selfInit.vbMaxIterations = nWarmUpIterations;
            selfInit.vbVerboseText = false;
            selfInit.vbVerbosePlot = false;
            
            for iWarm = 1:nWarmUps
                [~, trainings{iWarm}, priors{iWarm}] = vbBatch(selfInit, ds);
                if self.vbVerboseText
                    fprintf('\t\t\tTrial %d: Negative Free Energy: %0.2f\n',iWarm,trainings{iWarm}.negativeFreeEnergy);
                end
            end
            
            nfes = cellfun(@(c)c.negativeFreeEnergy,trainings);
            [~, bestWarmUp] = max(nfes);
            if self.vbVerboseText
                fprintf('\t\tResuming Trail %d\n',bestWarmUp);
            end
            
            trainings{bestWarmUp}.iterations.negativeFreeEnergy = trainings{bestWarmUp}.iterations.negativeFreeEnergy(end);
            trainings{bestWarmUp}.iterations.kld = trainings{bestWarmUp}.iterations.kld(end);
            trainings{bestWarmUp}.iterations.eLogLikelihood = trainings{bestWarmUp}.iterations.eLogLikelihood(end);
            
            % Final iterations
            [self, training, converged, err] = vbBatchIterate(self, priors{bestWarmUp}, ds, trainings{bestWarmUp});
            
            if self.vbCheckConvergence && self.vbVerboseText
                fprintf('\nAll VB iterations complete.\n\n')
            end
            if self.vbCheckConvergence && ~converged && ~err && self.vbVerboseText
                fprintf('\nLearning did not complete in the allotted number of iterations.\n\n')
            end
        end
    end    
    
    properties (Hidden)
        vbInitializationMethod = 'h0mixture'; %'random'        
    end
    
    methods (Access = protected, Hidden = true)
        function self = trainAction(self, ds)
            %[self, training] = vbBatch(self,ds);
            nWarmUps = 5;
            nWarmUpIterations = 5;
            self = vbBatchMultiWarmUp(self,ds,nWarmUps,nWarmUpIterations);
        end
        
        function ds = runAction(self, ds)
            ds = prtDataSetClass(approximateBagHypothesisProbablitiy(self, ds), ds.targets);
        end
    end
end
        
