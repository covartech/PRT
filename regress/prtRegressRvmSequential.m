classdef prtRegressRvmSequential < prtRegressRvm
    % prtRegressRvm  Relevance vector machine regression object
    %
    %   This code is based on:
    %
    %       Michael E Tipping, Sparse bayesian learning and the relevance 
    %       vector machine, The Journal of Machine Learning Research, Vol 1.
    %
    %   Also see http://en.wikipedia.org/wiki/Relevance_vector_machine
    % 
    %   A prtRegressionRvm object inherits the PLOT method from the
    %   prtRegress object, and the TRAIN, RUN, CROSSVALIDATE and KFOLDS
    %   methods from the prtAction object.
    %
    %   Example:
    %   
    %   dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
    %   dataSet.plot;                    % Display data
    %   reg = prtRegressRvmSequential;   % Create a prtRegressRvm object
    %   reg = reg.train(dataSet);        % Train the prtRegressRvm object
    %   reg.plot();                      % Plot the resulting curve
    %   dataSetOut = reg.run(dataSet);   % Run the regressor on the data
    %   hold on;
    %   plot(dataSet.getX,dataSetOut.getX,'c.') % Plot, overlaying the
    %                                           % fitted points with the 
    %                                           % curve and original data
    %   hold off;
    %   legend('Regression curve','Original Points','Selected Relevant Points','Fitted points',0)
    %
    %
    %   See also prtRegress, prtRegressGP, prtRegressLslr

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


    properties (Hidden = true)
        learningPoorlyScaledLikelihoodThreshold = 1e4;
        learningLikelihoodIncreaseThreshold = 1e-4;
        largestNumberOfGramColumns = 1000;
    end
    properties (SetAccess = 'protected',GetAccess = 'public')
        learningResults % Struct with information about the convergence
    end
    
    methods
         % Allow for string, value pairs
        function Obj = prtRegressRvmSequential(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            %Rvm = trainAction(Rvm,DataSet) (Private; see prtClass\train)
            %   Implements Jefferey's prior based training of a relevance
            %   vector machine.  The Rvm output from this function contains
            %   fields "sparseBeta" and "sparseKernels"
            %
            
            warningState = warning;
            
            if DataSet.nTargetDimensions ~= 1
                error('prt:prtRegressRvm:tooManyTargets','prtRegressRvm can only operate on single target data.');
            end
            
            y = DataSet.getTargets(:,1);
            
            localKernels = Obj.kernels.train(DataSet);
            nBasis = localKernels.nDimensions;
            Obj.beta = zeros(nBasis,1);
            
            if Obj.verboseText
                fprintf('Sequential RVM training with %d possible vectors.\n', nBasis);
            end
            
            relevantIndices = false(nBasis,1); % Nobody!
            
            alpha = inf(nBasis,1); % Initialize
            
            Obj.sigma2 = var(y)*0.1; % A descent guess
            
            % Find first kernel
            
            kernelCorrs = zeros(nBasis,1);
            nBlocks = ceil(nBasis./ Obj.largestNumberOfGramColumns);
            for iBlock = 1:nBlocks
                cInds = ((iBlock-1)*Obj.largestNumberOfGramColumns+1):min([iBlock*Obj.largestNumberOfGramColumns nBasis]);
                
                trainedKernelDownSelected = localKernels.retainKernelDimensions(cInds);
                blockPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                blockPhiNormalized = bsxfun(@rdivide,blockPhi,sqrt(sum(blockPhi.*blockPhi))); % We have to normalize here
                
                kernelCorrs(cInds) = abs(blockPhiNormalized'*y);
            end
            [maxVal, maxInd] = max(kernelCorrs); %#ok<ASGLU>
            
            
            % Start the actual Process
            if Obj.verboseText
                %fprintf('Sequential RVM training with %d possible vectors.\n', length(trainedKernels));
                fprintf('\t Iteration 0: Intialized with vector %d.\n', maxInd);
                
                nVectorsStringLength = ceil(log10(length(nBasis)))+1;
            end
            
            % Make this ind relevant
            relevantIndices(maxInd) = true;
            selectedInds = maxInd;
            
            if nBlocks == 1
                % If we have only 1 block we only need to do this once.
                trainedKernelDownSelected = localKernels.retainKernelDimensions(true(nBasis,1));
                PhiM = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
            end
            
            % Get the first relevant kernel matrix
            trainedKernelDownSelected = localKernels.retainKernelDimensions(relevantIndices);
            cPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
            
            % Start the actual Process
            for iteration = 1:Obj.learningMaxIterations
                
                % Store old log Alpha
                logAlphaOld = log(alpha);
                
                if iteration == 1
                    % Initial estimates
                    % Estimate Sigma, mu etc.
                    alpha(relevantIndices) = sum(cPhi.^2)./(kernelCorrs(relevantIndices) - Obj.sigma2);
                    
                    A = diag(alpha(relevantIndices));
                    
                    sigma2Inv = (Obj.sigma2^-1);
                    
                    SigmaInvChol = chol(A + sigma2Inv*(cPhi'*cPhi));
                    SigmaChol = inv(SigmaInvChol);
                    Obj.Sigma = SigmaChol*SigmaChol'; %#ok<MINV>
                    
                    mu = sigma2Inv*(Obj.Sigma*(cPhi'*y)); %mu = sigma2Inv*(SigmaInv\(cPhi'*y));
                    
                    yHat = cPhi*mu;
                end
                
                % Eval additions and subtractions
                Sm = zeros(nBasis,1);
                Qm = zeros(nBasis,1);
                cError = y-yHat;
                
                for iBlock = 1:nBlocks
                    cInds = ((iBlock-1)*Obj.largestNumberOfGramColumns+1):min([iBlock*Obj.largestNumberOfGramColumns nBasis]);
                    
                    if nBlocks > 1 % If there is only one block we can keep the on from before
                         trainedKernelDownSelected = localKernels.retainKernelDimensions(cInds);
                         PhiM = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                    end
                    
                    cProduct = sigma2Inv*(PhiM'*cPhi);
                    Sm(cInds) = sum((sigma2Inv*(PhiM.^2)).',2) - sum((cProduct*SigmaChol).^2,2);
                    Qm(cInds) = sigma2Inv*PhiM'*cError;
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
                
                % Removal
                removeLogLikelihoodChanges = -0.5*( qm.^2./(sm + alpha) - log(1 + sm./alpha) ); % Eq (37) (I think this is wrong in the paper. The one in the paper uses Si and Qi, I got this based on si and qi (or S and Q in their code), from corrected from analyzing code from http://www.vectoranomaly.com/downloads/downloads.htm)
                removeLogLikelihoodChanges(~relevantIndices) = 0; % Can't remove things not in
                
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
                    if remChange > 0
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
                
                if maxChangeVal > Obj.learningPoorlyScaledLikelihoodThreshold
                    warning('prtClassRvmSequential:BadKernelMatrix','Kernel matrix is poorly conditioned. Consider modifying your kernels or normalizing your features. Optimization Exiting...' );
                    break
                end
                
                switch actionInd
                    case 1 % Add
                        relevantIndices(bestAddInd) = true;
                        selectedInds = cat(1,selectedInds,bestAddInd);
                        alpha(bestAddInd) = updatedAlpha(bestAddInd);
                        
                    case 2 % Remove
                        relevantIndices(bestRemInd) = false;
                        selectedInds(selectedInds==bestRemInd) = [];
                        alpha(bestRemInd) = inf;
                        
                    case 3 % Modify
                        alpha(bestModInd) = updatedAlpha(bestModInd);
                end
                
                
                % At this point relevantIndices and alpha have changes.
                % Now we re-estimate Sigma, mu, and sigma2
                A = diag(alpha(relevantIndices));
                %cPhi = prtKernelGrammMatrix(DataSet,trainedKernels(relevantIndices));
                if nBlocks > 1
                    trainedKernelDownSelected = localKernels.retainKernelDimensions(relevantIndices);
                    cPhi = trainedKernelDownSelected.run_OutputDoubleArray(DataSet);
                else
                    cPhi = PhiM(:,relevantIndices);
                end
                
                % Re-estimate Sigma, mu
                sigma2Inv = 1./Obj.sigma2;
                
                SigmaInvChol = chol(A + sigma2Inv*(cPhi'*cPhi));
                SigmaChol = inv(SigmaInvChol);
                Obj.Sigma = SigmaChol*SigmaChol'; %#ok<MINV>
                
                mu = sigma2Inv*(Obj.Sigma*(cPhi'*y)); %mu = sigma2Inv*(SigmaInv\(cPhi'*y));
                
                % Find the current prediction
                yHat = cPhi*mu;
                
                % Re-estimate noise
                Obj.sigma2 = sum((y-yHat).^2)./(length(yHat) - sum(relevantIndices) + sum(alpha(relevantIndices).*diag(Obj.Sigma)));
                
                % Store beta
                Obj.beta = zeros(nBasis,1);
                Obj.beta(relevantIndices) = mu;
                
                if ~mod(iteration,Obj.verbosePlot)
                    if DataSet.nFeatures == 1
                        Obj.verboseIterationPlot(DataSet,relevantIndices);
                    elseif iteration == 1
                        warning('prt:prtRegressRvmSequential','Learning iteration plot can only be produced for training Datasets with 1 feature.');
                    end
                end
                
                % Check tolerance
                TOL = abs(log(alpha)-logAlphaOld);
                TOL(isnan(TOL)) = 0; % inf-inf = nan
                if all(TOL < Obj.learningConvergedTolerance) && iteration > 1
                    Obj.learningConverged = true;
                    Obj.learningResults.exitReason = 'Alpha Not Changing';
                    Obj.learningResults.exitValue = TOL;
                    if Obj.verboseText
                        fprintf('Exiting...Precisions no longer changing appreciably.\n\n');
                    end
                    break;
                end
                
                if Obj.verboseText
                    actionStrings = {sprintf('Addition: Vector %s has been added.  ', sprintf(sprintf('%%%dd',nVectorsStringLength),bestAddInd));
                        sprintf('Removal:  Vector %s has been removed.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestRemInd));
                        sprintf('Update:   Vector %s has been updated.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestModInd));};
                    fprintf('\t Iteration %d: %s Change in log-likelihood %g.\n',iteration, actionStrings{actionInd}, maxChangeVal);
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
