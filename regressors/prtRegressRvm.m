classdef prtRegressRvm < prtRegress
    % prtRegressRvm  Relevance vector machine regression object
    %
    %   REGRESS = prtRegressRvm returns a prtRegressRvm object
    %
    %    REGRESS = prtRegressRVM(PROPERTY1, VALUE1, ...) constructs a
    %    prtRegressRvm object REGRESS with properties as specified by
    %    PROPERTY/VALUE pairs.
    % 
    %    A prtRegressRvm object inherits all properties from the prtRegress
    %    class. In addition, it has the following properties:
    %
    %    kernels            - ???
    %    algorithm          - Allowable algorithms are 'JeffreysPrior' 
    %                         or 'Sequential'
    %    LearningConverged  - Flag indicating if the training converged
    %    LearningPlot       - Flag indicating whether or not to plot during
    %                         training
    %
    %    The following paremters are algorithm specific:
    %
    %    beta
    %    Sigma
    %    sigma2
    %    sparseBeta
    %    sparseKernels
    %    LearningMaxIterations
    %    LearningBetaConvergedTolerance 
    %    LearningBetaRelevantTolerance
    %    LearningLikelihoodIncreaseThreshold
    %    LearningResults   - ???
    % 
    %    Need refernence for RVMs.
    % 
    %   A prtRegressionRvm object inherits the PLOT method from the
    %   prtRegress object, and the TRAIN, RUN, CROSSVALIDATE and KFOLDS
    %   methods from the prtAction object.
    %
    %   Example:
    %   
    %   dataSet = prtDataSinc;           % Load a prtDataRegress
    %   dataSet.plot;                    % Display data
    %   reg = prtRegressRvm;             % Create a prtRegressRvm object
    %   reg = reg.train(dataSet);        % Train the prtRegressRvm object
    %   reg.plot();                      % Plot the resulting curve
    %   dataSetOut = reg.run(dataSet);   % Run the regressor on the data
    %   hold on;
    %   plot(dataSet.getX,dataSetOut.getX,'c.') % Plot, overlaying the
    %                                           % fitted points with the 
    %                                           % curve and original data
    % legend('Regression curve','Original Points','Fitted points',0)
    %
    %
    %   See also prtRegress, prtRegressGP, prtRegressLslr
    
    
    properties (SetAccess=private)
       
        name = 'Relevance Vector Machine'  % Relevance Vector Machine
        nameAbbreviation = 'RVM'           % RVM
        isSupervised = true;               % True
    end
    
    properties
        kernels = {prtKernelDc, prtKernelRbfNdimensionScale};
        algorithm = 'JefferysPrior';   %Allowable algorithms are 'JeffreysPrior' or 'Sequential'
        
        
        sigma2 = [];  % Estimated in training
        beta = [];% Estimated in training
        Sigma = [];% Estimated in training
        sparseBeta = [];% Estimated in training
        sparseKernels = {};% Estimated in training
        LearningConverged = [];% Whether or not the training converged
        
        
        LearningPlot = false;   % Whether or not to plot during training
        LearningMaxIterations = 1000;  % Maximum number of iteratoins
        LearningBetaConvergedTolerance = 1e-6;
        LearningBetaRelevantTolerance = 1e-3;
        LearningLikelihoodIncreaseThreshold = 1e-2;
        LearningResults % >????
    end
    
    methods
        
         % Allow for string, value pairs
        function Obj = prtRegressRvm(varargin)
           
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.algorithm(Obj,newAlgo)
            % ALGORITHM  Set the RVM algorithm.
            %
            % REGRESS = REGRESS.algorithm('JefferysPrior') sets the
            % algorithm of the REGRESS object to the Jefferys Prior
            % algorithm
            %
            % REGRESS = REGRESS.algorithm('Sequential') sets the
            % algorithm of the REGRESS object to the Sequential
            % algorithm
            possibleAlgorithms = {'Jefferys', 'Sequential'};
            
            possibleAlgorithmsStr = sprintf('%s, ',possibleAlgorithms{:});
            possibleAlgorithmsStr = possibleAlgorithmsStr(1:end-2);
            
            errorMessage = sprintf('Invalid algorithm. algorithm must be one of the following %s.',possibleAlgorithmsStr);
            assert(ischar(newAlgo),errorMessage);
            assert(ismember(newAlgo,possibleAlgorithms),errorMessage);
            
            Obj.algorithm = newAlgo;
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
            
            % Train (center) the kernels at the trianing data (if
            % necessary)
            trainedKernels = cell(size(Obj.kernels));
            for iKernel = 1:length(Obj.kernels);
                trainedKernels{iKernel} = initializeKernelArray(Obj.kernels{iKernel},DataSet);
            end
            trainedKernels = cat(1,trainedKernels{:});
            
            
            switch Obj.algorithm
                case 'JefferysPrior'
                    Obj = trainActionJefferysPrior(Obj, DataSet, y, trainedKernels);
                case 'Sequential'
                    Obj = trainActionSequential(Obj, DataSet, y, trainedKernels);
            end
            
            
            % Very bad training
            if isempty(Obj.sparseBeta)
                warning('prt:prtClassRvm:NoRelevantFeatures','No relevant features were found during training.');
            end
            
            % Reset warning
            warning(warningState);
            
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            
            if isempty(Obj.sparseBeta)
                DataSetOut = DataSet.setObservations(nan(DataSet.nObservations,DataSet.nFeatures));
                return
            end
            
            memChunkSize = 1000; % Should this be moved somewhere?
            n = DataSet.nObservations;
            
            DataSetOut = prtDataSetRegress(zeros(n,1));
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSetRegress(DataSet.getObservations(cI,:));
                gramm = prtKernelGrammMatrix(cDataSet,Obj.sparseKernels);
                
                DataSetOut = DataSetOut.setObservations(gramm*Obj.sparseBeta, cI);
            end
        end
    end
    
    methods (Access=private)
        function Obj = trainActionJefferysPrior(Obj, DataSet, y, trainedKernels)
            gramm = prtKernelGrammMatrix(DataSet,trainedKernels);
            nBasis = size(gramm,2);
            
            Obj.beta = zeros(nBasis,1);
            
            relevantIndices = true(nBasis,1); % Everybody!
            
            alpha = ones(nBasis,1); % Initialize
            
            Obj.sigma2 = var(y); % A descent guess
            
            for iteration = 1:Obj.LearningMaxIterations
                % Given currenet relevant stuff find the weight mean and
                % covariance
                cPhi = gramm(:,relevantIndices);
                A = diag(alpha(relevantIndices));
                
                sigma2Inv = (Obj.sigma2^-1);
                
                SigmaInv = A + sigma2Inv*(cPhi'*cPhi);
                Obj.Sigma = inv(SigmaInv);
                mu = sigma2Inv*(SigmaInv\(cPhi'*y));
                
                % Find the current prediction
                yHat = cPhi*mu;
                
                % Update A
                logAlphaOld = log(alpha(relevantIndices));
                
                cG = 1 - alpha(relevantIndices).*diag(Obj.Sigma);
                alpha(relevantIndices) = cG./(mu.^2);
                
                % Update sigma2
                Obj.sigma2 = norm(y-yHat)./(length(yHat) - sum(cG));
                
                Obj.beta = zeros(nBasis,1);
                Obj.beta(relevantIndices) = mu;
                
                %check tolerance for basis removal
                TOL = abs(log(alpha(relevantIndices))-logAlphaOld);
                if TOL < Obj.LearningBetaConvergedTolerance
                    Obj.LearningConverged = true;
                    break;
                end
                % We didn't break so we can contiue on
                
                if Obj.LearningPlot
                    subplot(1,2,1)
                    alphaPlot = log(alpha(2:end));
                    alphaPlot(~relevantIndices(2:end)) = nan;
                    
                    stem(DataSet.getObservations,alphaPlot);
                    ylabel('Log Weight Precision')
                    ylim([0 10]);
                end
                
                % Select relevant stuff
                relevantIndices = alpha < 1./Obj.LearningBetaRelevantTolerance;
                
                if Obj.LearningPlot
                    subplot(1,2,2)
                    [sortedObs,sortingInds] = sort(DataSet.getObservations());
                    
                    plot(sortedObs,yHat(sortingInds));
                    hold on
                    plot(DataSet.getObservations(),y,'.k')
                    % Here we assumed we have a bias;
                    plot(DataSet.getObservations(relevantIndices(2:end)),y(relevantIndices(2:end)),'ro')
                    hold off
                    subplot_title(sprintf('Iteration %d',iteration));
                    set(gcf,'color',[1 1 1])
                    drawnow;
                    
                    Obj.UserData.movieFrames(iteration) = getframe(gcf);
                end
                
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = trainedKernels(relevantIndices);
        end
        function Obj = trainActionSequential(Obj, DataSet, y, trainedKernels)
            
            nBasis = size(trainedKernels,1);
            Obj.beta = zeros(nBasis,1);
            
            relevantIndices = false(nBasis,1); % Nobody!
            
            alpha = inf(nBasis,1); % Initialize
            
            Obj.sigma2 = var(y)*0.1; % A descent guess
            
            % Find first kernel
            kernelCorrs = zeros(size(trainedKernels));
            kernelEnergies = zeros(size(trainedKernels));
            for iKernel = 1:length(trainedKernels)
                cVec = prtKernelGrammMatrix(DataSet,trainedKernels(iKernel));
                kernelEnergies(iKernel) = norm(cVec).^2;
                kernelCorrs(iKernel) = (cVec'*y)^2 / kernelEnergies(iKernel);
            end
            [maxVal, maxInd] = max(kernelCorrs);
            
            % Make this ind relevant
            relevantIndices(maxInd) = true;
            selectedInds = maxInd;
            % Start the actual Process
            for iteration = 1:Obj.LearningMaxIterations
                
                % Store old log Alpha
                logAlphaOld = log(alpha);
                
                if iteration == 1
                    % Initial estimates
                    % Estimate Sigma, mu etc.
                    alpha(relevantIndices) = kernelEnergies(relevantIndices)./(kernelCorrs(relevantIndices) - Obj.sigma2);
                    
                    A = diag(alpha(relevantIndices));
                    cPhi = prtKernelGrammMatrix(DataSet,trainedKernels(relevantIndices));
                    
                    sigma2Inv = (Obj.sigma2^-1);
                    
                    SigmaInvChol = chol(A + sigma2Inv*(cPhi'*cPhi));
                    SigmaChol = inv(SigmaInvChol);
                    Obj.Sigma = SigmaChol*SigmaChol';
                    
                    mu = sigma2Inv*(Obj.Sigma*(cPhi'*y)); %mu = sigma2Inv*(SigmaInv\(cPhi'*y));
                    
                    yHat = cPhi*mu;
                end
                
                % Eval additions and subtractions
                Sm = zeros(nBasis,1);
                Qm = zeros(nBasis,1);
                cError = y-yHat;
                
 %               cPhiProduct = cPhi*sigma2Inv;
                for iKernel = 1:nBasis
                    
                    PhiM = prtKernelGrammMatrix(DataSet,trainedKernels(iKernel));
                    %PhiM = bsxfun(@rdivide,PhiM,sqrt(sum(PhiM.^2)));
                    
%                    cPhiMProduct = PhiM*sigma2Inv;
                    
%                     Sm(iKernel) = cPhiMProduct'*PhiM - sum((PhiM'*cPhiProduct*SigmaChol).^2,2);
%                     
%                     Qm(iKernel) = PhiM'*cError; % According to vector anomaly code.
                    cProduct = sigma2Inv*(PhiM'*cPhi);
                    Sm(iKernel) = sigma2Inv*(PhiM'*PhiM) - sum((cProduct*SigmaChol).^2,2);
                    %Qm(iKernel) = sigma2Inv*(PhiM'*y) - cProduct*(Obj.Sigma*cPhi')*y*sigma2Inv;
                    Qm(iKernel) = sigma2Inv*PhiM'*cError;
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
                
                if maxChangeVal < Obj.LearningLikelihoodIncreaseThreshold
                    % There are no good options right now. Therefore we
                    % should exit with the previous iteration stats.
                    Obj.LearningConverged = true;
                    Obj.LearningResults.exitReason = 'No Good Actions';
                    Obj.LearningResults.exitValue = maxChangeVal;
                    break;
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
                
                
                if Obj.LearningPlot
                    subplot(1,2,1);
                    
                    stem(DataSet.getObservations(~isnan(addLogLikelihoodChanges(2:end))), addLogLikelihoodChanges([false; ~isnan(addLogLikelihoodChanges(2:end))]),'b')
                    hold on
                    stem(DataSet.getObservations(~isnan(removeLogLikelihoodChanges(2:end))), removeLogLikelihoodChanges([false; ~isnan(removeLogLikelihoodChanges(2:end))]),'r')
                    stem(DataSet.getObservations(~isnan(modifyLogLikelihoodChanges(2:end))), modifyLogLikelihoodChanges([false; ~isnan(modifyLogLikelihoodChanges(2:end))]),'g')
                    hold off
                    legend('Add','Remove','Modify')
                    ylabel('Change in Log Likelihood')
                    ylim([-5 20])
                end
                
                % At this point relevantIndices and alpha have changes.
                % Now we re-estimate Sigma, mu, and sigma2
                A = diag(alpha(relevantIndices));
                cPhi = prtKernelGrammMatrix(DataSet,trainedKernels(relevantIndices));
                
                % Re-estimate Sigma, mu
                sigma2Inv = 1./Obj.sigma2;
                
                SigmaInvChol = chol(A + sigma2Inv*(cPhi'*cPhi));
                SigmaChol = inv(SigmaInvChol);
                Obj.Sigma = SigmaChol*SigmaChol';
                
                mu = sigma2Inv*(Obj.Sigma*(cPhi'*y)); %mu = sigma2Inv*(SigmaInv\(cPhi'*y));
                
                % Find the current prediction
                yHat = cPhi*mu;
                
                % Re-estimate noise
                Obj.sigma2 = sum((y-yHat).^2)./(length(yHat) - sum(relevantIndices) + sum(alpha(relevantIndices).*diag(Obj.Sigma)));
                
                % Store beta
                Obj.beta = zeros(nBasis,1);
                Obj.beta(relevantIndices) = mu;
                
                if Obj.LearningPlot
                    subplot(1,2,2);
                    [sortedObs,sortingInds] = sort(DataSet.getObservations());
                    
                    plot(sortedObs,yHat(sortingInds));
                    hold on
                    plot(DataSet.getObservations(),y,'.k')
                    % Here we assumed we have a bias;
                    plot(DataSet.getObservations(relevantIndices(2:end)),y(relevantIndices(2:end)),'ro')
                    hold off
                    actionStrings = {'Add','Remove','Update'};
                    subplot_title(sprintf('%d - %s',iteration,actionStrings{actionInd}))
                    set(gcf,'color',[1 1 1])
                    drawnow;
                    
                    Obj.UserData.movieFrames(iteration) = getframe(gcf);
                end
                
                
                % Check tolerance
                TOL = abs(log(alpha)-logAlphaOld);
                TOL(isnan(TOL)) = 0; % inf-inf = nan
                if all(TOL < Obj.LearningBetaConvergedTolerance) && iteration > 1
                    Obj.LearningConverged = true;
                    Obj.LearningResults.exitReason = 'Alpha Not Changing';
                    Obj.LearningResults.exitValue = TOL;
                    break;
                end
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = trainedKernels(relevantIndices);
        end
    end
end
