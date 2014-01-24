classdef prtRvHmm < prtRv
    % prtRvHmm Hidden Markov model random variable
    %
    % rv = prtRvHmm creates a prtRvHmm object.  An HMM is defined by the
    % set of parameters {pi, transitionMatrix, components}, where
    % pi is a nStates x 1 vector of initial state probabilities,
    % transitionMatrix is a nStates x nStates matrix of state transitions,
    % and components is a nComponents x 1 vector specifying the
    % probability distributions within each state.
    %
    % Prior to learning an HMM, the component densities should be set to a
    % nStates x 1 vector of prtRv's - e.g., 
    % 
    %     gaussians = repmat(prtRvMvn,3,1);
    %     learnHmm = prtRvHmm('components',gaussians);
    %
    % prtRvHmm objects act just like other prtRv objects, they define
    % logPdf, etc.  
    %
    % Note that prtRvHmm objects make use of prtDataTypeTimeSeries data
    % sets, or cell arrays as input and output data.  For data specified as
    % a cell array, use a cell array of size #Observations x 1, with the
    % nth cell containing a matrix of size nTimeSamples(n) x nFeatures.
    %  
    %
    %  RV = prtRvHmm(PROPERTY1, VALUE1,...) creates a prtRvHmm object RV
    %   with properties as specified by PROPERTY/VALUE pairs.
    %
    %   A prtRvHmm object inherits all properties from the prtRv class. In
    %   addition, it has the following properties:
    %
    %   transitionMatrix  - A nStatex x nStates transition probability
    %                       matrix, where A(i,j) specifies the probability
    %                       of transitioning to state j from state i.
    %
    %   components        - A nStates x 1 array of prtRV objects which
    %                       serve as the within-state distributions.  Any
    %                       type of prtRV can be used, as long as the RV
    %                       defines the weightedMle method.  E.g.,
    %                       prtRvMvn, prtRvMultinomial, etc.
    %
    %   pi               - A 1 x nStates vector of intial state
    %                       probabilities.  Must sum to 1.
    %   
    %  A prtRvHmm object inherits all methods from the prtRv class. The MLE
    %  method can be used to estimate the distribution parameters from
    %  data.
    %
    % %Example usage:
    %   prtPath( 'alpha', 'beta' ); %for prtDataSetTimeSeries
    %   A = [.9 .1 0; 0 .9 .1; .1 0 .9];
    %   gaussians = repmat(prtRvMvn('sigma',eye(2)),3,1);
    %   gaussians(1).mu = [-2 -2];
    %   gaussians(2).mu = [2 -2];
    %   gaussians(3).mu = [2 2];
    %
    %   sourceHmm = prtRvHmm('pi',[1 1 1]/3,...
    %     'transitionMatrix',A,...
    %     'components',gaussians);
    %   x = sourceHmm.draw([100 100 100 100 100 100]);
    %   ds = prtDataSetTimeSeries(x);
    %
    %   gaussiansLearn = repmat(prtRvMvn,3,1);
    %   learnHmm = prtRvHmm('components',gaussiansLearn);
    %   learnHmm = learnHmm.mle(ds);
    %   learnHmm.logPdf(ds)
    %

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
        name = 'Hidden Markov Model'
        nameAbbreviation = 'RVHmm';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    properties
        components  % A vector of the components
        minimumComponentMembership = 0;
        nTrainingIterations = 3000;
    end
    
    properties (Dependent = true)
        pi
        transitionMatrix
        transitionProbabilities
        initialStateProbabilities
        nComponents       
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
    end
    
    properties (SetAccess = 'private', GetAccess = 'private', Hidden=true)
        transitionProbabilitiesDepHelper = prtRvMultinomial;
        initialStateProbabilitiesDepHelper = prtRvMultinomial;
        transitionMatrixDepStorage = [];
        transitionMatrixValid = false;
    end
    
    properties (Hidden = true)
        postMaximizationFunction = []; %@(self)self; 
        
        learningAutoInitialize = true;
        learningResults
        learningMaxIterations = 1000;
        learningConvergenceThreshold = 1e-6;
        learningApproximatelyEqualThreshold = 1e-4;
    end
    
    methods
        function self = prtRvHmm(varargin)
            self = constructorInputParse(self,varargin{:});
        end
    end
    
    
    % Set methods
    methods
        function self = set.initialStateProbabilities(self,weights)
            if isnumeric(weights)
                if isvector(weights) && prtUtilApproxEqual(sum(weights,2),1,sqrt(eps)*sqrt(length(weights)))
                    weights = prtRvMultinomial('probabilities',weights);
                else
                    error('prt:prtRvMixture','prtRvMixture mixinigProportions must be a vector of probabilities (that sum to 1) or a prtRvMultinomial');
                end
            end
            
            if ~isempty(weights) % For loading and saving
                assert(isa(weights,'prtRvMultinomial'),'prtRvMixture mixinigProportions must be a vector of probabilities (that sum to 1) or a prtRvMultinomial')
            end
            self.initialStateProbabilitiesDepHelper = weights;
        end
        
        function out = get.initialStateProbabilities(self)
            out = self.initialStateProbabilitiesDepHelper;
        end
        
        function self = set.transitionProbabilities(self,weights)
            if isnumeric(weights)
                if prtUtilApproxEqual(sum(weights,2),1,sqrt(eps)*sqrt(length(weights)))
                    multi = repmat(prtRvMultinomial,size(weights,1),1);
                    for i = 1:size(weights,1)
                    	%multi(i) = prtRvMultinomial('probabilities',weights(i,:));
                        multi(i).probabilities = weights(i,:);
                    end
                    weights = multi;
                else
                    error('prt:prtRvMixture','prtRvMixture mixinigProportions must be a vector of probabilities (that sum to 1) or a prtRvMultinomial');
                end
            end
            
            if ~isempty(weights) % For loading and saving
                assert(isa(weights,'prtRvMultinomial'),'prtRvMixture mixinigProportions must be a vector of probabilities (that sum to 1) or a prtRvMultinomial')
                multi = weights;
            end
            
            if self.nComponents > 0
                nSpecifiedComponents = self.nComponents;
                assert(multi(1).nCategories == nSpecifiedComponents,'The length of these mixingProportions does not mach the number of components of this prtRvMixture.')
            end
            
            self.transitionProbabilitiesDepHelper = weights;
            
            self.transitionMatrixValid = false;
            self.transitionMatrixDepStorage = self.transitionMatrix;
            self.transitionMatrixValid = true;
        end
        
        function val = get.transitionProbabilities(self)
            val = self.transitionProbabilitiesDepHelper;
            
            if ~isValid(val)
                val = [];
            end
        end
        
        function self = set.components(self,CompArray)
            if ~isempty(CompArray)
                assert(isa(CompArray(1),'prtRv') && isa(CompArray(1),'prtRvMemebershipModel'),'components must be a prtRv and inherit from prtRvMemebershipModel');
                assert(isvector(CompArray),'components must be an array of prtRv objects');
            end
            
            self.components = CompArray;
        end
        
        function A = get.transitionMatrix(self)
            A = [];
            if ~self.transitionMatrixValid
                for i = 1:length(self.transitionProbabilitiesDepHelper)
                    A = cat(1,A,self.transitionProbabilitiesDepHelper(i).probabilities);
                end
            else
                A = self.transitionMatrixDepStorage;
            end 
        end
        
        function self = set.transitionMatrix(self,A)
            self.transitionProbabilities = A;
        end
        
        function pi = get.pi(self)
            pi = self.initialStateProbabilities.probabilities;
        end
        
        function self = set.pi(self,val)
            self.initialStateProbabilities = val;
        end
    end
    
    methods
        
        function self = mle(self,inputData)
            
            
            xCell = dataInputParse(self,inputData);
            data = cat(1,xCell{:});
            
            if ~self.learningAutoInitialize && self.isValid
                % A valid HMM came in and we wanted to use that to
                % initialize.
                ll = nan(size(data,1),length(self.components));
                for state = 1:length(self.components)
                    ll(:,state) = self.components(state).logPdf(double(data));
                end
                %membershipMat = exp(bsxfun(@minus, ll, prtUtilSumExp(ll')'));
                
            else % Initialize membership matrices yourself
                
                [self, membershipMat] = initialComponentMembership(self,data);
                [self, membershipMat] = removeComponents(self,data,membershipMat);
                
                ll = membershipMat;
                
                if isempty(self.components)
                    error('prtRvHmm:noComponents','You must set rv.components to an nStates x 1 vector of prtRvs prior to calling MLE');
                end
                if isempty(self.pi)
                    self.pi = ones(1,self.nComponents)./self.nComponents;
                end
                if isempty(self.transitionMatrix)
                    temp = eye(length(self.components));
                    temp = temp + rand(size(temp));
                    temp = bsxfun(@rdivide,temp,sum(temp,2));
                    self.transitionMatrix = temp;
                end
            end
            
            alpha = cell(size(xCell));
            gamma = cell(size(xCell));
            xi = cell(size(xCell));
            
            start = 1;
            piDataSet = zeros(size(xCell,1), length(self.components));
            for cellInd = 1:length(xCell)
                stop = start + size(xCell{cellInd},1) - 1;
                cLogLike = ll(start:stop,:);
                [alpha{cellInd},~,gamma{cellInd},xi{cellInd}] = prtRvUtilLogForwardsBackwards(log(self.pi(:)'),log(self.transitionMatrix),cLogLike');
                
                piDataSet(cellInd, :) = exp(gamma{cellInd}(:,1) - prtUtilSumExp(gamma{cellInd}(:,1)));
                start = stop + 1;
            end
            
            pLogLikelihood = nan;
            self.learningResults.iterationLogLikelihood = [];
            
            piLoop = mean(piDataSet,1);
            
            for iteration = 1:self.nTrainingIterations
                
                %Update the components, A, pi
                gammaMat = cat(2,gamma{:});
                gammaMatExp = exp(gammaMat)';
                
                [self, gammaMatExp, componentRemoved,xi, piDataSet] = removeComponents(self,data,gammaMatExp,xi,piDataSet);

                self = maximizeParameters(self,data,gammaMatExp);
                
                % These are not done inside of maximize parameters for
                % speed purposes. 
                piLoop = mean(piDataSet,1);
                piLoop = piLoop ./ sum(piLoop,2);
                if any(isnan(piLoop))
                    piLoop = ones(1,size(gammaMatExp,2))./size(gammaMatExp,2);
                end
                
                A = sum(exp(cat(3,xi{:})),3);
                A = bsxfun(@rdivide,A,sum(A,2));
                
                if ~isempty(self.postMaximizationFunction)
                    self.pi = piLoop;
                    self.transitionProbabilities = A;
                    self = self.postMaximizationFunction(self);
                end
                
                %Estimate state p(x|state)
                ll = nan(size(data,1),length(self.components));
                for state = 1:length(self.components)
                    ll(:,state) = self.components(state).logPdf(data);
                end
                
                %Get forward/backwards, this updates alpha, gamma, for next
                %step
                piDataSet = zeros(size(xCell,1), length(self.components));
                start = 1;
                logPi = log(piLoop(:)');
                logA = log(A);
                for cellInd = 1:length(xCell)
                    stop = start + size(xCell{cellInd},1) - 1;
                    cLl = ll(start:stop,:);
                    [alpha{cellInd},~,gamma{cellInd},xi{cellInd}] = prtRvUtilLogForwardsBackwards(logPi,logA,cLl');
                    
                    piDataSet(cellInd, :) = exp(gamma{cellInd}(:,1) - prtUtilSumExp(gamma{cellInd}(:,1)));
                    start = stop + 1;
                end
                
                cLogLikelihood = sum(cellfun(@(c)prtUtilSumExp(c(:,end)),alpha));
                % or could have used % cLogLikelihood = sum(logPdf(self,inputData));
                
                self.learningResults.iterationLogLikelihood(end+1) = cLogLikelihood;
                
                if ~componentRemoved
                    if abs(cLogLikelihood - pLogLikelihood)*abs(mean([cLogLikelihood  pLogLikelihood])) < self.learningConvergenceThreshold
                        break
                    elseif (pLogLikelihood - cLogLikelihood) > self.learningApproximatelyEqualThreshold
                        warning('prt:prtRvMixture:learning','Log-Likelihood has decreased!!! Exiting.');
                        break
                    else
                        pLogLikelihood = cLogLikelihood;
                    end
                else
                    pLogLikelihood = cLogLikelihood;
                end
                
            end
            self.learningResults.nIterations = iteration;
            
            % Pack up parameters into self, these would otherwise be slower
            % than necessary
            if isempty(self.postMaximizationFunction)
                self.pi = piLoop;
                self.transitionProbabilities = A;
            end
            
            
            
        end
        
        function [y, stateLogPdf] = pdf(self,X)
            X = self.dataInputParse(X); % Basic error checking etc
            
            assert(size(X{1},2) == self.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), self.nDimensions)
            
            [isValid, reasonStr] = self.isValid;
            assert(isValid,'PDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            [logy, stateLogPdf] = logPdf(self,X);
            
            y = exp(logy);
            if nargout > 1
                for i = 1:length(stateLogPdf)
                    stateLogPdf{i} = exp(stateLogPdf{i});
                end
            end
        end
        
        function mixture = toMixture(self)
            mixture = prtRvMixture('components',self.components,'mixingProportions',ones(size(self.components))./length(self.components));
            mixture.minimumComponentMembership = self.minimumComponentMembership;
        end
        
        function plotPdf(self)
            plotPdf(self.toMixture);
        end
        
        function plotLogPdf(self)
            plotLogPdf(self.toMixture);
        end
        
        function [logPdf, stateLogPdf] = logPdf(self,X)
            
            X = self.dataInputParse(X); % Basic error checking etc
            assert(size(X{1},2) == self.nDimensions,'Data, RV dimensionality missmatch. Input data, X, has dimensionality %d and this RV has dimensionality %d.', size(X,2), self.nDimensions)
            
            [isValid, reasonStr] = self.isValid;
            assert(isValid,'LOGPDF cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            stateLogPdf = cell(size(X));
            logPdf = nan(size(X));
            
            %                         for cellInd = 1:length(X)
            %                             data = X{cellInd};
            %
            %                             ll = nan(size(data,1),self.nComponents);
            %                             for state = 1:length(self.components)
            %                                 ll(:,state) = self.components(state).logPdf(double(data));
            %                             end
            %                             alpha = prtRvUtilLogForwardsBackwards(log(self.pi(:)'),log(self.transitionMatrix),ll');
            %                             stateLogPdf{cellInd} = alpha;
            %                             logPdf(cellInd) = prtUtilSumExp(alpha(:,end));
            %                         end
            
            % PT, 2013.04.09 - process the whole data set at once... much
            % faster:
            xMat = cat(1,X{:});
            ll = nan(size(xMat,1),self.nComponents);
            for state = 1:length(self.components)
                ll(:,state) = self.components(state).logPdf(double(xMat));
            end
            llCell = mat2cell(ll,cellfun(@(c)size(c,1),X),size(ll,2));
            logPi = log(self.pi(:)');
            logA = log(self.transitionMatrix);
            for cellInd = 1:length(X)
                alpha = prtRvUtilLogForwardsBackwards(logPi,logA,llCell{cellInd}');
                stateLogPdf{cellInd} = alpha;
                logPdf(cellInd) = prtUtilSumExp(alpha(:,end));
            end
            
        end
        
        function y = cdf(self,X)
            error('prtRvHmm:cdf','CDF not defined for HMMs')
        end
        
        function [vals, states] = draw(self,nTimeSamples)
            
            [isValid, reasonStr] = self.isValid;
            assert(isValid,'DRAW cannot yet be evaluated. This RV is not yet valid %s.',reasonStr);
            
            %
            vals = {};
            states = {};
            for obsInd = 1:length(nTimeSamples)
                state = self.initialStateProbabilities.draw(1);
                for time = 1:nTimeSamples(obsInd);
                    states{obsInd,1}(time,:) = state(:);
                    state = find(state);
                    vals{obsInd,1}(time,:) = self.components(state).draw(1);
                    state = self.transitionProbabilities(state).draw(1);
                end
            end
        end
    end
    
    % Get Methods
    methods
        function val = get.nDimensions(self)
            if self.nComponents > 0
                val = self.components(1).nDimensions;
            else
                val = [];
            end
        end
        
        function val = get.nComponents(self)
            val = length(self.components);
        end
    end
    
    methods (Hidden=true)
        function [val, reasonStr] = isValid(self)
            if numel(self) > 1
                val = false(size(self));
                for iR = 1:numel(self)
                    [val(iR), reasonStr] = isValid(self(iR));
                end
                return
            end
            
            
            if ~isempty(self.components)
                val = all(isValid(self.components)) && self.initialStateProbabilities.isValid && all(isValid(self.transitionProbabilities));
            else
                val = false;
            end
            
            if val
                reasonStr = '';
            else
                unsetComps = isempty(self.components);
                invalidComps = ~all(isValid(self.components));
                try
                    badProbs = ~self.initialStateProbabilities.isValid;
                catch
                    badProbs = true;
                end
                try
                    badTrans = ~all(isValid(self.transitionProbabilities));
                catch
                    badTrans = true;
                end
                
                if unsetComps && ~badProbs
                    reasonStr = 'because components has not been set';
                elseif unsetComps && badProbs
                    reasonStr = 'because components and mixingProportions have not been set';
                elseif ~unsetComps && badProbs && invalidComps
                    reasonStr = 'because mixingProportions have not been set and some components are not yet valid';
                elseif ~unsetComps && ~badProbs && invalidComps
                    reasonStr = 'because some components are not yet valid';
                elseif ~unsetComps && badProbs && ~invalidComps
                    reasonStr = 'because mixingProportions have not been set';
                elseif badTrans
                    reasonStr = 'because transitionProbabilities have not been set';
                else
                    reasonStr = 'because of an unknown reason';
                end
            end
            
        end
    end
    
    methods (Hidden = true)
        function val = plotLimits(self)
            [isValid, reasonStr] = self.isValid;
            if isValid
                allPlotLimits = zeros(self.nComponents,self.nDimensions*2);
                for iComp = 1:self.nComponents
                    try
                        allPlotLimits(iComp,:) = self.components(iComp).plotLimits();
                    catch msg %#ok
                        cval = [Inf -Inf];
                        allPlotLimits(iComp,:) = repmat(cval,1,self.nDimensions);
                    end
                end
                
                val = zeros(1,2*self.nDimensions);
                val(1:2:self.nDimensions*2-1) = min(allPlotLimits(:,(1:2:self.nDimensions*2-1)),[],1);
                val(2:2:self.nDimensions*2) = max(allPlotLimits(:,(2:2:self.nDimensions*2)),[],1);
            else
                error('prtRvMixture:plotLimits','Plotting limits can not be determined for this prtRvMixture. It is not yet valid %s',reasonStr)
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % These Methods are private helper functions for mle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'protected')
        
        function [self, initMembershipMat] = initialComponentMembership(self,X)
            [self.components, initMembershipMat] = initializeMixtureMembership(self.components,X);
        end
        
        function membershipMat = expectedComponentMembership(self,X)
            
            [logy, membershipMat] = logPdf(self,X); %#ok

            membershipMat = exp(bsxfun(@minus,membershipMat,prtUtilSumExp(membershipMat')'));
            
        end
        
        function self = maximizeParameters(self,X,membershipMat)
            temp = self.components;
            for iComp = 1:self.nComponents
                try
                    temp(iComp) = weightedMle(temp(iComp),X,membershipMat(:,iComp));
                catch  %#ok<CTCH>
                    error('prt:prtRvMixture:maximizeParameters','An error was encountered while fitting the parameters of component %d. Perhaps the number of components is too high.',iComp)
                end
            end
            self.components = temp;
        end
        
        function [self, membershipMat, componentRemoved, xi, piDataSet] = removeComponents(self, X, membershipMat,xi,piDataSet)
            
            nSamplesPerComponent = sum(membershipMat,1);
            componentsToRemove = nSamplesPerComponent < self.minimumComponentMembership;
            
            %Never remove ALL the components; if we try to do that, just
            %remove one
            if all(componentsToRemove) && isscalar(componentsToRemove)
                error('Attempt to remove the last remaining component.');
            end
            if all(componentsToRemove)
                componentsToRemove(nSamplesPerComponent > min(nSamplesPerComponent)) = false;
            end
            componentRemoved = any(componentsToRemove);
            
            if componentRemoved
                retain = ~componentsToRemove;
                membershipMat = membershipMat(:,retain);
                membershipMat = bsxfun(@rdivide,membershipMat,sum(membershipMat,2));
            
                self.components = self.components(retain);
                
                for iObs = 1:length(xi)
                    xi{iObs} = xi{iObs}(retain, retain,:);
                end
                piDataSet = piDataSet(:,retain);
               
            end
        end
        
    end
    
    methods (Access = 'protected', Hidden = true)
        function X = dataInputParse(self,X) %#ok<MANU>
            % dataInputParse - Parse inputs for RVs that only require the
            % data. Since most RVs need only the observations (X). This
            % function allows RVs to operate on prtDataSetStandard()s and 
            % a data matrix.
            
            if isa(X,'cell')
                return;
            elseif isnumeric(X) || islogical(X)
                % Quick exit from this ifelse so we don't call isa
                % which can be slow
                X = {X};
            elseif isa(X,'prtDataSetTimeSeries')
                X = X.getObservations();
            else
                error('prt:prtRv','Input to mle() must be a matrix of data, a cell array of matrices, or a prtDataSetTimeSeries.');
            end
            
        end
    end
end
