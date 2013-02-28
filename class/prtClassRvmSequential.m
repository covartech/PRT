classdef prtClassRvmSequential < prtClassRvm
    % prtClassRvmSequential  Relevance vector machine classifier using sequential training
    % 
    %   CLASSIFIER = prtClassRvmSequential returns a relevance vector
    %   machine classifier based using sequential training.
    %
    %   CLASSIFIER = prtClassRvmSequential(PROPERTY1, VALUE1, ...)
    %   constructs a prtClassRvmSequential object CLASSIFIER with properties as
    %   specified by PROPERTY/VALUE pairs.
    %
    %    A prtClassRvmSequential object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    kernels                - A cell array of prtKernel objects specifying
    %                             the kernels to use
    %    verbosePlot            - Flag indicating whether or not to plot during
    %                             training
    %    verboseText            - Flag indicating whether or not to output
    %                             verbose updates during training
    %    learningMaxIterations  - The maximum number of iterations
    %
    %    A prtClassRvmSequential also has the following read-only properties:
    %
    %    learningConverged  - Flag indicating if the training converged
    %    beta               - The regression weights, estimated during training
    %    sparseBeta         - The sparse regression weights, estimated during
    %                         training
    %    sparseKernels      - The sparse regression kernels, estimated during
    %                         training
    %
    %   For more information on the algorithm and the above properties, see
    %   the following reference:
    %
    %   Tipping, M. E. and A. C. Faul (2003). Fast marginal likelihood
    %   maximisation for sparse Bayesian models. In C. M. Bishop and B. J.
    %   Frey (Eds.), Proceedings of the Ninth International Workshop on
    %   Artificial Intelligence and Statistics, Key West, FL, Jan 3-6.
    %
    %   prtClassRvmSequential is most useful for datasets with a large
    %   number of observations for which the gram matrix can not be held in
    %   memory. The sequential RVM training algorithm is capable of
    %   operating by generating necessary portions of the gram matrix when
    %   needed. The size of the generated portion of the gram matrix is
    %   determined by the property, largestNumberOfGramColumns. Sequential
    %   RVM training will attempt to generate portions of the gram matrix
    %   that are TraingData.nObservations x largesNumberofGramColums in
    %   size. If the entire gram matrix is this size or smaller it need
    %   only be generated once. Therefore if the entire gram matrix can be
    %   stored in memory, training is much faster. For quickest operation,
    %   largestNumberOfGramColumns should be set as large as possible
    %   without exceeding RAM limitations.
    %
    %    Example:
    %
    %    TestDataSet = prtDataGenUnimodal;      % Create some test and
    %    TrainingDataSet = prtDataGenUnimodal;  % training data classifier
    %    classifier = prtClassRvmSequential('verbosePlot',true); % Create a classifier
    %    classifier = classifier.train(TrainingDataSet);    % Train
    %    classified = run(classifier, TestDataSet);         % Test
    %    % Plot
    %    subplot(2,1,1); classifier.plot;
    %    subplot(2,1,2); [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %    h = plot(pf,pd,'linewidth',3);
    %    title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %   See also prtClass, prtClassRvm, prtClassRvnFiguerido,
    %   prtRegressRvmSequential

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
    properties

        learningPoorlyScaledLikelihoodThreshold = 1e4;
        learningLikelihoodIncreaseThreshold = 1e-6;
        largestNumberOfGramColumns = 5000;
        learningCorrelationRemovalThreshold = 0.99;
        learningFactorRemove = true;   % Remove kernels during train?
        learningRepeatedActionLimit = 25;
    end
    
    properties(Hidden = true)
        learningResults
    end
    
    properties (Hidden = true)
        Sigma = [];
    end
    
    methods
        function Obj = prtClassRvmSequential(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.learningPoorlyScaledLikelihoodThreshold(Obj,val)
            assert(prtUtilIsPositiveScalar(val),'prt:prtClassRvmSequential:learningPoorlyScaledLikelihoodThreshold','learningPoorlyScaledLikelihoodThreshold must be a positive scalar');
            Obj.learningPoorlyScaledLikelihoodThreshold = val;
        end
        function Obj = set.learningLikelihoodIncreaseThreshold(Obj,val)
            assert(prtUtilIsPositiveScalar(val),'prt:prtClassRvmSequential:learningLikelihoodIncreaseThreshold','learningLikelihoodIncreaseThreshold must be a positive scalar');
            Obj.learningLikelihoodIncreaseThreshold = val;
        end
        function Obj = set.largestNumberOfGramColumns(Obj,val)
            assert(prtUtilIsPositiveScalarInteger(val),'prt:prtClassRvmSequential:largestNumberOfGramColumns','largestNumberOfGramColumns must be a positive integer scalar');
            Obj.largestNumberOfGramColumns = val;
        end
        function Obj = set.learningCorrelationRemovalThreshold(Obj,val)
            assert(prtUtilIsPositiveScalar(val),'prt:prtClassRvmSequential:learningCorrelationRemovalThreshold','learningCorrelationRemovalThreshold must be a positive scalar');
            Obj.learningCorrelationRemovalThreshold = val;
        end
        function Obj = set.learningFactorRemove(Obj,val)
            assert(prtUtilIsLogicalScalar(val),'prt:prtClassRvmSequential:learningFactorRemove','learningFactorRemove must be a logical scalar');
            Obj.learningFactorRemove = val;
        end
        function Obj = set.learningRepeatedActionLimit(Obj,val)
            assert(prtUtilIsPositiveScalarInteger(val),'prt:prtClassRvmSequential:learningRepeatedActionLimit','learningRepeatedActionLimit must be a positive integer scalar');
            Obj.learningRepeatedActionLimit = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        function Obj = trainAction(Obj,DataSet)
            %Rvm = trainAction(Rvm,DataSet) (Private; see prtClass\train)
                        
            warningState = warning;
            %warning off MATLAB:nearlySingularMatrix
            
            y = Obj.getMinusOneOneTargets(DataSet);
            
            localKernels = Obj.kernels.train(DataSet);
            nBasis = localKernels.nDimensions;
            
            if false && nBasis <= Obj.largestNumberOfGramColumns
                Obj = trainActionSequentialInMemory(Obj, DataSet, y);
                return
            end
            
            if Obj.verboseText
                fprintf('Sequential RVM training with %d possible vectors.\n', nBasis);
            end
            
            % The sometimes we want y [-1 1] but mostly not
            ym11 = y;
            y(y ==-1) = 0;
            
            Obj.beta = zeros(nBasis,1);
            
            relevantIndices = false(nBasis,1); % Nobody!
            alpha = inf(nBasis,1); % Nobody!
            forbidden = zeros(nBasis,1); % Will hold who is forbidding you from joining
            
            % Find first kernel
            kernelCorrs = zeros(nBasis,1);
            nBlocks = ceil(nBasis./ Obj.largestNumberOfGramColumns);
            for iBlock = 1:nBlocks
                cInds = ((iBlock-1)*Obj.largestNumberOfGramColumns+1):min([iBlock*Obj.largestNumberOfGramColumns nBasis]);
                
                trainedKernelDownSelected = localKernels.retainKernelDimensions(cInds);
                blockPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                blockPhiNormalized = bsxfun(@rdivide,blockPhi,sqrt(sum(blockPhi.*blockPhi))); % We have to normalize here
                
                kernelCorrs(cInds) = abs(blockPhiNormalized'*ym11);
            end
            [maxVal, maxInd] = max(kernelCorrs); %#ok<ASGLU>
            
            
            % Make this ind relevant
            relevantIndices(maxInd) = true;
            selectedInds = maxInd;
            
            % Add things to forbidden list
            initLogical = false(nBasis,1);
            initLogical(maxInd) = true;
            firstKernel = localKernels.retainKernelDimensions(initLogical);
            firstPhiNormalized = firstKernel.run_OutputDoubleArray(DataSet);
            firstPhiNormalized = firstPhiNormalized - mean(firstPhiNormalized);
            firstPhiNormalized = firstPhiNormalized./sqrt(sum(firstPhiNormalized.^2));
            phiCorrs = zeros(nBasis,1);
            for iBlock = 1:nBlocks
                cInds = ((iBlock-1)*Obj.largestNumberOfGramColumns+1):min([iBlock*Obj.largestNumberOfGramColumns nBasis]);
                
                trainedKernelDownSelected = localKernels.retainKernelDimensions(cInds);
                if nBlocks > 1 % If there is only one block we can keep the one from before
                    blockPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                end
                blockPhiDemeanedNormalized = bsxfun(@minus,blockPhi,mean(blockPhi));
                blockPhiDemeanedNormalized = bsxfun(@rdivide,blockPhiDemeanedNormalized,sqrt(sum(blockPhiDemeanedNormalized.*blockPhiDemeanedNormalized))); % We have to normalize here
                
                phiCorrs(cInds) = blockPhiDemeanedNormalized'*firstPhiNormalized;
            end
            forbidden(phiCorrs > Obj.learningCorrelationRemovalThreshold) = maxInd;
            
            % Start the actual Process
            if Obj.verboseText
                fprintf('\t Iteration 0: Intialized with vector %d.\n', maxInd);
                
                nVectorsStringLength = ceil(log10(length(nBasis)))+1;
            end
            
            if nBlocks == 1
                % If we have only 1 block we only need to do this once.
                trainedKernelDownSelected = localKernels.retainKernelDimensions(true(nBasis,1));
                PhiM = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
            end
            
            % Get the first relevant kernel matrix
            trainedKernelDownSelected = localKernels.retainKernelDimensions(relevantIndices);
            cPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
            
            repeatedActionCounter = 0;
            for iteration = 1:Obj.learningMaxIterations
                
                % Store old log Alpha
                logAlphaOld = log(alpha);
                
                if iteration == 1
                    % Initial estimates
                    % Estimate Sigma, mu etc.
                    
                    logOut = (ym11*0.9+1)/2;
                    mu = cPhi \ log(logOut./(1-logOut));
                    
                    alpha(relevantIndices) = 1./mu.^2;
                    
                    % Laplacian approx. IRLS
                    A = diag(alpha(relevantIndices));
                    
                    [mu, SigmaInvChol, obsNoiseVar] = prtUtilPenalizedIrls(y,cPhi,mu,A);
                    
                    SigmaChol = inv(SigmaInvChol);
                    Obj.Sigma = SigmaChol*SigmaChol'; %#ok<MINV>
                    
                    yHat = 1 ./ (1+exp(-cPhi*mu));
                end
                
                % Eval additions and subtractions
                Sm = zeros(nBasis,1);
                Qm = zeros(nBasis,1);
                cError = y-yHat;
                
                cPhiProduct = bsxfun(@times,cPhi,obsNoiseVar);
                for iBlock = 1:nBlocks
                    cInds = ((iBlock-1)*Obj.largestNumberOfGramColumns+1):min([iBlock*Obj.largestNumberOfGramColumns nBasis]);
                    

                    if nBlocks > 1 % If there is only one block we can keep the on from before
                        trainedKernelDownSelected = localKernels.retainKernelDimensions(cInds);
                        PhiM = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                    end
                    
                    Sm(cInds) = (obsNoiseVar'*(PhiM.^2)).' - sum((PhiM.'*cPhiProduct*SigmaChol).^2,2);
                    Qm(cInds) = PhiM.'*cError;
                end
                
                % Find little sm and qm (these are different for relevant vectors)
                sm = Sm;
                qm = Qm;
                
                cDenom = (alpha(relevantIndices)-Sm(relevantIndices));
                sm(relevantIndices) = alpha(relevantIndices) .* Sm(relevantIndices) ./ cDenom;
                qm(relevantIndices) = alpha(relevantIndices) .* Qm(relevantIndices) ./ cDenom;
                
                theta = qm.^2 - sm;
                cantBeRelevent = theta < 0;
                
                % Addition
                addLogLikelihoodChanges = 0.5*( theta./Sm + log(Sm ./ Qm.^2) ); % Eq (27)
                addLogLikelihoodChanges(cantBeRelevent) = 0; % Can't add things that are disallowed by theta
                addLogLikelihoodChanges(relevantIndices) = 0; % Can't add things already in
                addLogLikelihoodChanges(forbidden > 0) = 0; % Can't add things that are forbidden
                
                % Removal
                removeLogLikelihoodChanges = -0.5*( qm.^2./(sm + alpha) - log(1 + sm./alpha) ); % Eq (37) (I think this is wrong in the paper. The one in the paper uses Si and Qi, I got this based on si and qi (or S and Q in their code), from corrected from analyzing code from http://www.vectoranomaly.com/downloads/downloads.htm)
                removeLogLikelihoodChanges(~relevantIndices) = 0; % Can't remove things not in
                removeLogLikelihoodChanges(imag(removeLogLikelihoodChanges) > 0) = inf;
                
                % Modify
                updatedAlpha = sm.^2 ./ theta;
                updatedAlphaDiff = 1./updatedAlpha - 1./alpha;
                modifyLogLikelihoodChanges = 0.5*( updatedAlphaDiff.*(Qm.^2) ./ (updatedAlphaDiff.*Sm + 1) - log(1 + Sm.*updatedAlphaDiff) );
                
                modifyLogLikelihoodChanges(~relevantIndices) = 0; % Can't modify things not in
                modifyLogLikelihoodChanges(cantBeRelevent) = 0; % Can't modify things that technically shouldn't be in (they would get dropped)
                
                
                [addChange, bestAddInd] = max(addLogLikelihoodChanges);
                [remChange, bestRemInd] = max(removeLogLikelihoodChanges);
                [modChange, bestModInd] = max(modifyLogLikelihoodChanges);
                
                if iteration == 1
                    % On the first iteration we don't allow removal
                    [maxChangeVal, actionInd] = max([addChange, nan, modChange]);
                else
                    if remChange > 0 && Obj.learningFactorRemove
                        % Removing is top priority.
                        % If removing increases the likelihood, we have two
                        % options, actually remove that sample or modify that
                        % sample if that is better
                        [maxChangeVal, actionInd] = max([nan remChange, modifyLogLikelihoodChanges(bestRemInd)]);
                    else
                        % Not going to remove, so we would be allowed to modify
                        [maxChangeVal, actionInd] = max([addChange, remChange, modChange]);
                    end
                end
                
                if maxChangeVal > Obj.learningPoorlyScaledLikelihoodThreshold
                    warning('prtClassRvm:BadKernelMatrix','Kernel matrix is poorly conditioned. Consider modifying your kernels. Optimization Exiting...' );
                    break
                end
                
                if maxChangeVal < Obj.learningLikelihoodIncreaseThreshold
                    % There are no good options right now. Therefore we
                    % should exit with the previous iteration stats.
                    Obj.learningConverged = true;
                    Obj.learningResults.exitReason = 'No Good Actions';
                    Obj.learningResults.exitValue = maxChangeVal;
                    if Obj.verboseText
                        fprintf('Convergence criterion met, no necessary actions remaining, maximal change in log-likelihood %g\n\n',maxChangeVal);
                    end
                    
                    break;
                end
                
                switch actionInd
                    case 1
                        cBestInd = bestAddInd;
                    case 2
                        cBestInd = bestRemInd;
                    case 3
                        cBestInd = bestModInd;
                end
                if iteration > 1 && lastAction == actionInd && cBestInd == lastInd
                    repeatedActionCounter = repeatedActionCounter + 1;
                else
                    repeatedActionCounter = 0;
                end
                
                if repeatedActionCounter >= Obj.learningRepeatedActionLimit
                    if Obj.verboseText
                        fprintf('Exiting... repeating action limit has been reached.\n\n');
                    end
                    return
                end
                
                if Obj.verboseText
                    actionStrings = {sprintf('Addition: Vector %s has been added.  ', sprintf(sprintf('%%%dd',nVectorsStringLength),bestAddInd));
                                     sprintf('Removal:  Vector %s has been removed.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestRemInd));
                                     sprintf('Update:   Vector %s has been updated.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestModInd));};
                    fprintf('\t Iteration %d: %s Change in log-likelihood %g.\n',iteration, actionStrings{actionInd}, maxChangeVal);
                end
                
                lastAction = actionInd;
                switch actionInd
                    case 1 % Add
                        
                        relevantIndices(bestAddInd) = true;
                        selectedInds = cat(1,selectedInds,bestAddInd);
                        
                        alpha(bestAddInd) = updatedAlpha(bestAddInd);
                        % Modify Mu
                        % (Penalized IRLS will fix it soon but we need good initialization)
                        
                        trainedKernelDownSelected = localKernels.retainKernelDimensions(bestAddInd);
                        newPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                        
                        cFactor = (Obj.Sigma*(cPhi)'*(newPhi.*obsNoiseVar));
                        Sigmaii = 1./(updatedAlpha(bestAddInd) + Sm(bestAddInd));
                        newMu = Sigmaii*Qm(bestAddInd);
                        
                        updatedOldMu = mu - newMu*cFactor;
                        sortedSelected = sort(selectedInds);
                        newMuLocation = find(sortedSelected==bestAddInd);
                        
                        mu = zeros(length(mu)+1,1);
                        mu(setdiff(1:length(mu),newMuLocation)) = updatedOldMu;
                        mu(newMuLocation) = newMu;
                        
                        
                        % Add things to forbidden list
                        newPhiDemeanedNormalized = newPhi - mean(newPhi);
                        newPhiDemeanedNormalized = newPhiDemeanedNormalized./sqrt(sum(newPhiDemeanedNormalized.^2));
                        phiCorrs = zeros(nBasis,1);
                        for iBlock = 1:nBlocks
                            cInds = ((iBlock-1)*Obj.largestNumberOfGramColumns+1):min([iBlock*Obj.largestNumberOfGramColumns nBasis]);
                            
                            if nBlocks > 1
                                trainedKernelDownSelected = localKernels.retainKernelDimensions(cInds);
                                blockPhiDemeanedNormalized = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                                
                                blockPhiDemeanedNormalized = bsxfun(@minus,blockPhiDemeanedNormalized,mean(blockPhiDemeanedNormalized));
                                blockPhiDemeanedNormalized = bsxfun(@rdivide,blockPhiDemeanedNormalized,sqrt(sum(blockPhiDemeanedNormalized.*blockPhiDemeanedNormalized))); % We have to normalize here
                                
                            %else we have this from before
                            end
                            
                            phiCorrs(cInds) = blockPhiDemeanedNormalized'*newPhiDemeanedNormalized;
                        end
                        forbidden(phiCorrs > Obj.learningCorrelationRemovalThreshold) = bestAddInd;
                        
                        lastInd = bestAddInd;
                    case 2 % Remove
                        
                        removingInd = sort(selectedInds)==bestRemInd;
                        
                        mu = mu + mu(removingInd) .* Obj.Sigma(:,removingInd) ./ Obj.Sigma(removingInd,removingInd);
                        mu(removingInd) = [];
                        
                        relevantIndices(bestRemInd) = false;
                        selectedInds(selectedInds==bestRemInd) = [];
                        alpha(bestRemInd) = inf;
                        
                        % Anything this guy said is forbidden is now
                        % allowed.
                        forbidden(forbidden == bestRemInd) = 0;
                        
                        lastInd = bestRemInd;
                        
                    case 3 % Modify
                        modifyInd = sort(selectedInds)==bestModInd;
                        
                        alphaChangeInv = 1/(updatedAlpha(bestModInd) - alpha(bestModInd));
                        kappa = 1/(Obj.Sigma(modifyInd,modifyInd) + alphaChangeInv);
                        mu = mu - mu(modifyInd)*kappa*Obj.Sigma(:,modifyInd);
                        
                        alpha(bestModInd) = updatedAlpha(bestModInd);
                        
                        lastInd = bestModInd;
                end
                
                % At this point relevantIndices and alpha have changes.
                % Now we re-estimate Sigma, mu, and sigma2
                if nBlocks > 1
                    trainedKernelDownSelected = localKernels.retainKernelDimensions(relevantIndices);
                    cPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                else
                    cPhi = PhiM(:,relevantIndices);
                end
                
                % Laplacian approx. IRLS
                A = diag(alpha(relevantIndices));
                
                if isempty(cPhi)
                    yHat = 0.5*ones(size(y));
                else
                    [mu, SigmaInvChol, obsNoiseVar] = prtUtilPenalizedIrls(y,cPhi,mu,A);
                    
                    SigmaChol = inv(SigmaInvChol);
                    Obj.Sigma = SigmaChol*SigmaChol'; %#ok<MINV>
                    
                    yHat = 1 ./ (1+exp(-cPhi*mu)); % We use a logistic here. 
                end
                
                % Store beta
                Obj.beta = zeros(nBasis,1);
                Obj.beta(relevantIndices) = mu;
                
                if ~mod(iteration,Obj.verbosePlot)
                    if DataSet.nFeatures == 2
                        Obj.verboseIterationPlot(DataSet,relevantIndices);
                    elseif iteration == 1
                        warning('prt:prtClassRvmSequential','Learning iteration plot can only be produced for training Datasets with 2 features');
                    end
                end
                
                % Check tolerance
                changeVal = abs(log(alpha)-logAlphaOld);
                changeVal(isnan(changeVal)) = 0; % inf-inf = nan
                if all(changeVal < Obj.learningConvergedTolerance) && iteration > 1
                    Obj.learningConverged = true;
                    Obj.learningResults.exitReason = 'Alpha Not Changing';
                    Obj.learningResults.exitValue = TOL;
                    if Obj.verboseText
                        fprintf('Exiting...Precisions no longer changing appreciably.\n\n');
                    end
                    break;
                end
            end
            
            if Obj.verboseText && iteration == Obj.learningMaxIterations
                fprintf('Exiting...Convergence not reached before the maximum allowed iterations was reached.\n\n');
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = localKernels.retainKernelDimensions(relevantIndices);
            
            % Very bad training
            if isempty(Obj.sparseBeta)
                warning('prt:prtClassRvm:NoRelevantFeatures','No relevant features were found during training.');
            end
            
            % Reset warning
            warning(warningState);
            
        end
    end
end
