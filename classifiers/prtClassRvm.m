classdef prtClassRvm < prtClass
    % prtClassRvm  Relevance vector machin classifier
    %
    %    CLASSIFIER = prtClassRvm returns a relevance vector machine classifier
    %
    %    CLASSIFIER = prtClassRvm(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassRvm object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassRvm object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    algorithm          - The algorithm used, can be 'Figueiredo',
    %                         'Sequential', or 'SequentialInMemory'
    %    LearningConverged  - Flag indicating if the training converged
    %    LearningPlot       - Flag indicating whether or not to plot during
    %                         training
    %    LearningMaxIterations  - The maximum number of iterations
    %
    %    beta          - The regression weights, estimated during training
    %    sparseBeta    - The sparse regression weights, estimated during
    %                    training
    %    sparseKernels - The sparse regression kernels, estimated during
    %                    training
    %
    %    The following paremters are algorithm specific:
    %
    %         LearningBetaConvergedTolerance
    %         LearningBetaRelevantTolerance
    %         LearningLikelihoodIncreaseThreshold
    %         LearningSequentialBlockSize
    %         LearningCorrelationRemovalThreshold
    %         LearningSequentialFavorRemove
    %         LearningResults ???
    %
    %    For information on relevance vector machines, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/Relevance_vector_machine
    %
    %    A prtClassRvm object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUnimodal;      % Create some test and
    %     TrainingDataSet = prtDataGenUnimodal;  % training data
    %     classifier = prtClassRvm;           % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classes  = classified.getX > .5;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
   
    
    properties (SetAccess=private)
       
        name = 'Relevance Vector Machine'  % Relevance Vector Machine
        nameAbbreviation = 'RVM'           % RVM
        isSupervised = true;               % True
        
        
        isNativeMary = false;  % False
    end
    
    properties
        kernels = {prtKernelDc, prtKernelRbfNdimensionScale};
        algorithm = 'Figueiredo';  % The training algorithm
        
        % Estimated Parameters
        
        Sigma = [];
        beta = [];
        sparseBeta = [];
        sparseKernels = {};
        
        % Learning algorithm
        
        LearningPlot = false;
        LearningText = false;
        LearningConverged = false;
        LearningMaxIterations = 1000;
        LearningBetaConvergedTolerance = 1e-3;
        LearningBetaRelevantTolerance = 1e-3;
        LearningLikelihoodIncreaseThreshold = 1e-6;
        LearningSequentialBlockSize = 1000;
        LearningCorrelationRemovalThreshold = 0.99;
        LearningSequentialFavorRemove = true;
        LearningResults
    end
    
    methods
        
        function Obj = prtClassRvm(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.algorithm(Obj,newAlgo)
            possibleAlgorithms = {'Figueiredo', 'Sequential', 'SequentialInMemory'};
            
            possibleAlgorithmsStr = sprintf('%s, ',possibleAlgorithms{:});
            possibleAlgorithmsStr = possibleAlgorithmsStr(1:end-2);
            
            errorMessage = sprintf('Invalid algorithm. algorithm must be one of the following %s.',possibleAlgorithmsStr);
            assert(ischar(newAlgo),errorMessage);
            assert(ismember(newAlgo,possibleAlgorithms),errorMessage);
            
            Obj.algorithm = newAlgo;
        end
        
        function varargout = plot(Obj)
            % plot - Plot output confidence of the prtClassRvm object
            %
            %   CLASS.plot plots the output confidence of the prtClassRvm
            %   object. The dimensionality of the dataset must be 3 or
            %   less, and verboseStorage must be true.
            
            HandleStructure = plot@prtClass(Obj);
            
            % Plot the kernels
            hold on
            for iKernel = 1:length(Obj.sparseKernels)
                Obj.sparseKernels{iKernel}.classifierPlot();
            end
            hold off
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            %Rvm = trainAction(Rvm,DataSet) (Private; see prtClass\train)
            %   Implements Jefferey's prior based training of a relevance
            %   vector machine.  The Rvm output from this function contains
            %   fields "sparseBeta" and "sparseKernels"
            %
            
            warningState = warning;
            %warning off MATLAB:nearlySingularMatrix
            
            if ~DataSet.isBinary
                error('prt:prtClassRvm:nonBinaryData','prtClassRvm requires a binary data set');
            end
            
            %Note: do not assume that getTargets returns a double array or
            %values "0" and "1", instead use this:
            yMat = double(DataSet.getTargetsAsBinaryMatrix());
            y = nan(size(yMat,1),1);
            y(yMat(:,1) == 1) = -1;
            y(yMat(:,2) == 1) = 1;
            
            % Train (center) the kernels at the trianing data (if
            % necessary)
            trainedKernels = cell(size(Obj.kernels));
            for iKernel = 1:length(Obj.kernels);
                trainedKernels{iKernel} = initializeKernelArray(Obj.kernels{iKernel},DataSet);
            end
            trainedKernels = cat(1,trainedKernels{:});
            
            switch Obj.algorithm
                case 'Figueiredo'
                    Obj = trainActionFigueiredo(Obj, DataSet, y, trainedKernels);
                case 'Sequential'
                    Obj = trainActionSequential(Obj, DataSet, y, trainedKernels);
                case 'SequentialInMemory'
                    Obj = trainActionSequentialInMemory(Obj, DataSet, y, trainedKernels);
                    
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
            
            
            
            OutputMat = zeros(n,1);
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSetClass(DataSet.getObservations(cI,:));
                gramm = prtKernelGrammMatrix(cDataSet,Obj.sparseKernels);
                
                OutputMat(cI) = normcdf(gramm*Obj.sparseBeta);
            end
            DataSetOut = prtDataSetClass(OutputMat);
        end
    end
    methods (Access=private)
        function Obj = trainActionFigueiredo(Obj, DataSet, y, trainedKernels)
            
            gramm = prtKernelGrammMatrix(DataSet,trainedKernels);
            nBasis = size(gramm,2);
            
            sigmaSquared = eps;
            
            %Check to make sure the problem is well-posed.  This can be fixed either
            %with changes to kernels, or by regularization
            G = gramm'*gramm;
            while rcond(G) < 1e-6
                if sigmaSquared == eps
                    warning('prt:prtClassRvm:illConditionedG','RVM initial G matrix ill-conditioned; regularizing diagonal of G to resolve; this can be modified by changing kernel parameters\n');
                end
                G = (sigmaSquared*eye(nBasis) + gramm'*gramm);
                sigmaSquared = sigmaSquared*2;
            end
            Obj.beta = G\gramm'*y;
            
            u = diag(abs(Obj.beta));
            relevantIndices = 1:size(gramm,2);
            
            h1Ind = y == 1;
            h0Ind = y == -1;
            
            for iteration = 1:Obj.LearningMaxIterations
                
                %%%%
                %%See: Figueiredo: "Adaptive Sparseness For Supervised Learning"
                %%%%
                uK = u(relevantIndices,relevantIndices);
                grammK = gramm(:,relevantIndices);
                
                S = gramm*Obj.beta;
                
                S(h1Ind) = S(h1Ind) + normpdf(S(h1Ind))./(1-normcdf(-S(h1Ind)));
                S(h0Ind) = S(h0Ind) - normpdf(S(h0Ind))./(normcdf(-S(h0Ind)));
                
                beta_OLD = Obj.beta;
                
                A = (eye(size(uK)) + uK*(grammK'*grammK)*uK);
                B = uK*(grammK'*S);    %this is correct - see equation (21)
                
                Obj.beta(relevantIndices,1) = uK*(A\B);
                
                % Remove irrelevant vectors
                relevantIndices = find(abs(Obj.beta) > max(abs(Obj.beta))*Obj.LearningBetaRelevantTolerance);
                irrelevantIndices = abs(Obj.beta) <= max(abs(Obj.beta))*Obj.LearningBetaRelevantTolerance;
                
                Obj.beta(irrelevantIndices,1) = 0;
                u = diag(abs(Obj.beta));
                
                if Obj.LearningPlot && DataSet.nFeatures == 2
                    DsSummary = DataSet.summarize;
                    
                    [linGrid, gridSize,xx,yy] = prtPlotUtilGenerateGrid(DsSummary.lowerBounds, DsSummary.upperBounds, Obj.PlotOptions);
                    cPhi = prtKernelGrammMatrix(prtDataSetClass(linGrid),trainedKernels(relevantIndices));
                    
                    confMap = reshape(normcdf(cPhi*Obj.beta(relevantIndices)),gridSize);
                    imagesc(xx(1,:),yy(:,1),confMap,[0,1])
                    colormap(Obj.PlotOptions.twoClassColorMapFunction());
                    axis xy
                    hold on
                    plot(DataSet);
                    for iRel = 1:length(relevantIndices)
                        trainedKernels{relevantIndices(iRel)}.classifierPlot();
                    end
                    hold off
                    
                    set(gcf,'color',[1 1 1])
                    drawnow;
                    
                    Obj.UserData.movieFrames(iteration) = getframe(gcf);
                end
                
                %check tolerance for basis removal
                TOL = norm(Obj.beta-beta_OLD)/norm(beta_OLD);
                if TOL < Obj.LearningBetaConvergedTolerance
                    Obj.LearningConverged = true;
                    break;
                end
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = trainedKernels(relevantIndices);
            
        end
        function Obj = trainActionSequential(Obj, DataSet, y, trainedKernels)
            
            if size(trainedKernels,1) <= Obj.LearningSequentialBlockSize
                Obj = trainActionSequentialInMemory(Obj, DataSet, y, trainedKernels);
                return
            end
            
            if Obj.LearningText
                fprintf('Sequential RVM training with %d possible vectors.\n', length(trainedKernels));
            end
            
            % The sometimes we want y [-1 1] but mostly not
            ym11 = y;
            y(y ==-1) = 0;
            
            nBasis = size(trainedKernels,1);
            Obj.beta = zeros(nBasis,1);
            
            relevantIndices = false(nBasis,1); % Nobody!
            alpha = inf(nBasis,1); % Nobody!
            forbidden = zeros(nBasis,1); % Will hold who is forbidding you from joining
            
            % Find first kernel
            kernelCorrs = zeros(size(trainedKernels));
            nBlocks = ceil(length(trainedKernels)./ Obj.LearningSequentialBlockSize);
            for iBlock = 1:nBlocks
                cInds = ((iBlock-1)*Obj.LearningSequentialBlockSize+1):min([iBlock*Obj.LearningSequentialBlockSize nBasis]);
                cPhi = prtKernelGrammMatrix(DataSet, trainedKernels(cInds));
                cPhi = bsxfun(@rdivide,cPhi,sqrt(sum(cPhi.*cPhi))); % We have to normalize here
                kernelCorrs(cInds) = abs(cPhi'*ym11);
            end
            [maxVal, maxInd] = max(kernelCorrs);
            
            % Make this ind relevant
            relevantIndices(maxInd) = true;
            selectedInds = maxInd;
            
            % Add things to forbidden list
            newPhi = prtKernelGrammMatrix(DataSet, trainedKernels(maxInd));
            newPhi = newPhi - mean(newPhi);
            newPhi = newPhi./sqrt(sum(newPhi.^2));
            phiCorrs = zeros(size(trainedKernels));
            for iBlock = 1:nBlocks
                cInds = ((iBlock-1)*Obj.LearningSequentialBlockSize+1):min([iBlock*Obj.LearningSequentialBlockSize nBasis]);
                cPhi = prtKernelGrammMatrix(DataSet, trainedKernels(cInds));
                cPhi = bsxfun(@minus,cPhi,mean(cPhi));
                cPhi = bsxfun(@rdivide,cPhi,sqrt(sum(cPhi.*cPhi))); % We have to normalize here
                
                phiCorrs(cInds) = cPhi'*newPhi;
            end
            forbidden(phiCorrs > Obj.LearningCorrelationRemovalThreshold) = maxInd;
            
            % Start the actual Process
            if Obj.LearningText
                %fprintf('Sequential RVM training with %d possible vectors.\n', length(trainedKernels));
                fprintf('\t Iteration 0: Intialized with vector %d.\n', maxInd);
                
                nVectorsStringLength = ceil(log10(length(trainedKernels)))+1;
            end
            
            
            
            for iteration = 1:Obj.LearningMaxIterations
                
                % Store old log Alpha
                logAlphaOld = log(alpha);
                
                if iteration == 1
                    % Initial estimates
                    % Estimate Sigma, mu etc.
                    
                    % Make up a mu (least squares?) and an alpha (made up)
                    cPhi = prtKernelGrammMatrix(DataSet,trainedKernels(relevantIndices));
                    %cPhi = bsxfun(@rdivide,cPhi,sqrt(sum(cPhi.^2)));
                    
                    logOut = (ym11*0.9+1)/2;
                    mu = cPhi \ log(logOut./(1-logOut));
                    %mu = cPhi \ y;
                    alpha(relevantIndices) = 1./mu.^2;
                    
                    % Laplacian approx. IRLS
                    A = diag(alpha(relevantIndices));
                    
                    [mu, SigmaInvChol, obsNoiseVar] = prtUtilPenalizedIrls(y,cPhi,mu,A);
                    
                    SigmaChol = inv(SigmaInvChol);
                    Obj.Sigma = SigmaChol*SigmaChol';
                    
                    yHat = 1 ./ (1+exp(-cPhi*mu));
                end
                
                % Eval additions and subtractions
                Sm = zeros(nBasis,1);
                Qm = zeros(nBasis,1);
                cError = y-yHat;
                
                cPhiProduct = bsxfun(@times,cPhi,obsNoiseVar);
                for iBlock = 1:nBlocks
                    cInds = ((iBlock-1)*Obj.LearningSequentialBlockSize+1):min([iBlock*Obj.LearningSequentialBlockSize nBasis]);
                    PhiM = prtKernelGrammMatrix(DataSet, trainedKernels(cInds));
                    %PhiM = bsxfun(@rdivide,PhiM,sqrt(sum(PhiM.^2)));
                    
                    Sm(cInds) = (obsNoiseVar'*(PhiM.^2)).' - sum((PhiM.'*cPhiProduct*SigmaChol).^2,2);
                    Qm(cInds) = PhiM.'*cError;
                end
                
                %                 % One at a time method
                %                 for iKernel = 1:nBasis
                %                     PhiM = prtKernelGrammMatrix(DataSet,trainedKernels(iKernel));
                %                     cPhiMProduct = bsxfun(@times,PhiM,obsNoiseVar);
                %
                %                     Sm2(iKernel) = cPhiMProduct'*PhiM - sum((PhiM'*cPhiProduct*SigmaChol).^2,2);
                %                     Qm2(iKernel) = PhiM'*cError; % According to vector anomaly code.
                %                 end
                
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
                    if remChange > 0 && Obj.LearningSequentialFavorRemove
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
                
                if maxChangeVal > 1e3
                    warning('prtClassRvm:BadKernelMatrix','Kernel matrix is poorly conditioned. Consider modifying your kernels' );
                    keyboard
                end
                
                if maxChangeVal < Obj.LearningLikelihoodIncreaseThreshold
                    % There are no good options right now. Therefore we
                    % should exit with the previous iteration stats.
                    Obj.LearningConverged = true;
                    Obj.LearningResults.exitReason = 'No Good Actions';
                    Obj.LearningResults.exitValue = maxChangeVal;
                    if Obj.LearningText
                        fprintf('Exiting...no necessary actions remaining, maximal change in log-likelihood %g\n',maxChangeVal);
                    end
                    
                    break;
                end
                
                if Obj.LearningText
                    actionStrings = {sprintf('Addition: Vector %s has been added.  ', sprintf(sprintf('%%%dd',nVectorsStringLength),bestAddInd));
                        sprintf('Removal:  Vector %s has been removed.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestRemInd));
                        sprintf('Update:   Vector %s has been updated.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestModInd));};
                    fprintf('\t Iteration %d: %s Change in log-likelihood %g.\n',iteration, actionStrings{actionInd}, maxChangeVal);
                end
                
                
                switch actionInd
                    case 1 % Add
                        
                        relevantIndices(bestAddInd) = true;
                        selectedInds = cat(1,selectedInds,bestAddInd);
                        
                        alpha(bestAddInd) = updatedAlpha(bestAddInd);
                        % Modify Mu
                        % (Penalized IRLS will fix it soon but we need good initialization)
                        
                        newPhi = prtKernelGrammMatrix(DataSet,trainedKernels(bestAddInd));
                        %newPhi = newPhi./sqrt(sum(newPhi.^2));
                        
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
                        newPhi = prtKernelGrammMatrix(DataSet, trainedKernels(bestAddInd));
                        newPhi = newPhi - mean(newPhi);
                        newPhi = newPhi./sqrt(sum(newPhi.^2));
                        phiCorrs = zeros(size(trainedKernels));
                        for iBlock = 1:nBlocks
                            cInds = ((iBlock-1)*Obj.LearningSequentialBlockSize+1):min([iBlock*Obj.LearningSequentialBlockSize nBasis]);
                            cPhi = prtKernelGrammMatrix(DataSet, trainedKernels(cInds));
                            cPhi = bsxfun(@minus,cPhi,mean(cPhi));
                            cPhi = bsxfun(@rdivide,cPhi,sqrt(sum(cPhi.*cPhi))); % We have to normalize here
                            
                            phiCorrs(cInds) = cPhi'*newPhi;
                        end
                        forbidden(phiCorrs > Obj.LearningCorrelationRemovalThreshold) = bestAddInd;
                        
                        
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
                        
                    case 3 % Modify
                        modifyInd = sort(selectedInds)==bestModInd;
                        
                        alphaChangeInv = 1/(updatedAlpha(bestModInd) - alpha(bestModInd));
                        kappa = 1/(Obj.Sigma(modifyInd,modifyInd) + alphaChangeInv);
                        mu = mu - mu(modifyInd)*kappa*Obj.Sigma(:,modifyInd);
                        
                        alpha(bestModInd) = updatedAlpha(bestModInd);
                end
                
                % At this point relevantIndices and alpha have changes.
                % Now we re-estimate Sigma, mu, and sigma2
                cPhi = prtKernelGrammMatrix(DataSet,trainedKernels(relevantIndices));
                %cPhi = bsxfun(@rdivide,cPhi,sqrt(sum(cPhi.^2)));
                
                % Laplacian approx. IRLS
                A = diag(alpha(relevantIndices));
                
                if isempty(cPhi)
                    yHat = 0.5*ones(size(y));
                else
                    [mu, SigmaInvChol, obsNoiseVar] = prtUtilPenalizedIrls(y,cPhi,mu,A);
                    
                    SigmaChol = inv(SigmaInvChol);
                    Obj.Sigma = SigmaChol*SigmaChol';
                    
                    yHat = 1 ./ (1+exp(-cPhi*mu));
                end
                
                % Store beta
                Obj.beta = zeros(nBasis,1);
                Obj.beta(relevantIndices) = mu;
                
                if Obj.LearningPlot && DataSet.nFeatures == 2
                    figure(101)
                    DsSummary = DataSet.summarize;
                    
                    [linGrid, gridSize,xx,yy] = prtPlotUtilGenerateGrid(DsSummary.lowerBounds, DsSummary.upperBounds, Obj.PlotOptions);
                    cPhiPlot = prtKernelGrammMatrix(prtDataSetClass(linGrid),trainedKernels(relevantIndices));
                    
                    confMap = reshape(normcdf(cPhiPlot*Obj.beta(relevantIndices)),gridSize);
                    imagesc(xx(1,:),yy(:,1),confMap,[0 1])
                    colormap(Obj.PlotOptions.twoClassColorMapFunction());
                    axis xy
                    hold on
                    plot(DataSet);
                    relevantIndicesFind = find(relevantIndices);
                    for iRel = 1:length(relevantIndicesFind)
                        trainedKernels{relevantIndicesFind(iRel)}.classifierPlot();
                    end
                    
                    hold off
                    actionStrings = {'Add','Remove','Update'};
                    title(sprintf('%d - %s',iteration,actionStrings{actionInd}))
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
                    if Obj.LearningText
                        fprintf('Exiting...Precisions no longer changine appreciably.\n');
                    end
                    break;
                end
            end
            
            
            if Obj.LearningText && iteration == Obj.LearningMaxIterations
                fprintf('Exiting...Convergence not reached before the maximum allowed iterations was reached.\n');
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = trainedKernels(relevantIndices);
        end
        function Obj = trainActionSequentialInMemory(Obj, DataSet, y, trainedKernels)
            
            if Obj.LearningText
                fprintf('Sequential RVM training with %d possible vectors.\n', length(trainedKernels));
            end
            
            % Generate the Gram Matrix only once
            PhiM = prtKernelGrammMatrix(DataSet, trainedKernels);
            PhiMNorm = bsxfun(@minus,PhiM,mean(PhiM));
            stds = std(PhiM,0,1);
            stds(stds==0) = 1; % Bias would turn in to nans
            PhiMNorm = bsxfun(@rdivide,PhiMNorm,stds);
            
            % The sometimes we want y [-1 1] but mostly not
            ym11 = y;
            y(y ==-1) = 0;
            
            nBasis = size(trainedKernels,1);
            Obj.beta = zeros(nBasis,1);
            
            relevantIndices = false(nBasis,1); % Nobody!
            alpha = inf(nBasis,1); % Nobody!
            forbidden = zeros(nBasis,1); % Will hold who is forbidding you from joining
            
            % Find first kernel
            kernelCorrs = abs(bsxfun(@rdivide,PhiM,sqrt(sum(PhiM.^2,1)))'*ym11);
            
            [maxVal, maxInd] = max(kernelCorrs);
            
            % Make this ind relevant
            relevantIndices(maxInd) = true;
            selectedInds = maxInd;
            % Start the actual Process
            
            if Obj.LearningText
                %fprintf('Sequential RVM training with %d possible vectors.\n', length(trainedKernels));
                fprintf('\t Iteration 0: Intialized with vector %d.\n', maxInd);
                
                nVectorsStringLength = ceil(log10(length(trainedKernels)))+1;
            end
            
            % Add things to forbidden list
            newPhi = prtKernelGrammMatrix(DataSet, trainedKernels(maxInd));
            newPhi = newPhi - mean(newPhi);
            stds = sqrt(sum(newPhi.^2));
            stds(stds==0) = 1; % Bias would turn in to nans
            newPhi = newPhi./stds;
            
            phiCorrs = PhiMNorm'*newPhi;
            
            forbidden(phiCorrs > Obj.LearningCorrelationRemovalThreshold) = maxInd;
            
            
            for iteration = 1:Obj.LearningMaxIterations
                
                % Store old log Alpha
                logAlphaOld = log(alpha);
                
                if iteration == 1
                    % Initial estimates
                    % Estimate Sigma, mu etc.
                    
                    % Make up a mu (least squares?) and an alpha (made up)
                    cPhi = PhiM(:,relevantIndices);
                    %cPhi = bsxfun(@rdivide,cPhi,sqrt(sum(cPhi.^2)));
                    
                    logOut = (ym11*0.9+1)/2;
                    mu = cPhi \ log(logOut./(1-logOut));
                    %mu = cPhi \ y;
                    alpha(relevantIndices) = 1./mu.^2;
                    
                    % Laplacian approx. IRLS
                    A = diag(alpha(relevantIndices));
                    
                    [mu, SigmaInvChol, obsNoiseVar] = prtUtilPenalizedIrls(y,cPhi,mu,A);
                    
                    SigmaChol = inv(SigmaInvChol);
                    Obj.Sigma = SigmaChol*SigmaChol';
                    
                    yHat = 1 ./ (1+exp(-cPhi*mu));
                end
                
                % Eval additions and subtractions
                cError = y-yHat;
                
                cPhiProduct = bsxfun(@times,cPhi,obsNoiseVar);
                Sm = (obsNoiseVar'*(PhiM.^2))' - sum((PhiM'*cPhiProduct*SigmaChol).^2,2);
                Qm = PhiM'*cError;
                
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
                    if remChange > 0 && Obj.LearningSequentialFavorRemove
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
                    if Obj.LearningText
                        fprintf('Exiting...no necessary actions remaining, maximal change in log-likelihood %g\n',maxChangeVal);
                    end
                    
                    break;
                end
                
                if maxChangeVal > 1e3
                    warning('prtClassRvm:BadKernelMatrix','Kernel matrix is poorly conditioned. Consider modifying your kernels' );
                end
                
                if Obj.LearningText
                    actionStrings = {sprintf('Addition: Vector %s has been added.  ', sprintf(sprintf('%%%dd',nVectorsStringLength),bestAddInd));
                        sprintf('Removal:  Vector %s has been removed.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestRemInd));
                        sprintf('Update:   Vector %s has been updated.', sprintf(sprintf('%%%dd',nVectorsStringLength), bestModInd));};
                    fprintf('\t Iteration %d: %s Change in log-likelihood %g.\n',iteration, actionStrings{actionInd}, maxChangeVal);
                end
                
                
                switch actionInd
                    case 1 % Add
                        
                        relevantIndices(bestAddInd) = true;
                        selectedInds = cat(1,selectedInds,bestAddInd);
                        
                        alpha(bestAddInd) = updatedAlpha(bestAddInd);
                        % Modify Mu
                        % (Penalized IRLS will fix it soon but we need good initialization)
                        
                        newPhi = prtKernelGrammMatrix(DataSet,trainedKernels(bestAddInd));
                        %newPhi = newPhi./sqrt(sum(newPhi.^2));
                        
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
                        newPhi = prtKernelGrammMatrix(DataSet, trainedKernels(bestAddInd));
                        newPhi = newPhi - mean(newPhi);
                        stds = sqrt(sum(newPhi.^2));
                        stds(stds==0) = 1; % Bias would turn in to nans
                        newPhi = newPhi./stds;
                        
                        phiCorrs = PhiMNorm'*newPhi;
                        forbidden(phiCorrs > Obj.LearningCorrelationRemovalThreshold) = bestAddInd;
                        
                        
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
                        
                    case 3 % Modify
                        modifyInd = sort(selectedInds)==bestModInd;
                        
                        alphaChangeInv = 1/(updatedAlpha(bestModInd) - alpha(bestModInd));
                        kappa = 1/(Obj.Sigma(modifyInd,modifyInd) + alphaChangeInv);
                        mu = mu - mu(modifyInd)*kappa*Obj.Sigma(:,modifyInd);
                        
                        alpha(bestModInd) = updatedAlpha(bestModInd);
                end
                
                % At this point relevantIndices and alpha have changes.
                % Now we re-estimate Sigma, mu, and sigma2
                cPhi = PhiM(:,relevantIndices);
                %cPhi = bsxfun(@rdivide,cPhi,sqrt(sum(cPhi.^2)));
                
                % Laplacian approx. IRLS
                A = diag(alpha(relevantIndices));
                
                [mu, SigmaInvChol, obsNoiseVar] = prtUtilPenalizedIrls(y,cPhi,mu,A);
                
                SigmaChol = inv(SigmaInvChol);
                Obj.Sigma = SigmaChol*SigmaChol';
                
                yHat = 1 ./ (1+exp(-cPhi*mu));
                
                % Store beta
                Obj.beta = zeros(nBasis,1);
                Obj.beta(relevantIndices) = mu;
                
                if Obj.LearningPlot && DataSet.nFeatures == 2
                    figure(101)
                    DsSummary = DataSet.summarize;
                    
                    [linGrid, gridSize,xx,yy] = prtPlotUtilGenerateGrid(DsSummary.lowerBounds, DsSummary.upperBounds, Obj.PlotOptions);
                    cPhiPlot = prtKernelGrammMatrix(prtDataSetClass(linGrid),trainedKernels(relevantIndices));
                    
                    confMap = reshape(normcdf(cPhiPlot*Obj.beta(relevantIndices)),gridSize);
                    imagesc(xx(1,:),yy(:,1),confMap,[0 1])
                    colormap(Obj.PlotOptions.twoClassColorMapFunction());
                    axis xy
                    hold on
                    plot(DataSet);
                    relevantIndicesFind = find(relevantIndices);
                    for iRel = 1:length(relevantIndicesFind)
                        trainedKernels{relevantIndicesFind(iRel)}.classifierPlot();
                    end
                    
                    hold off
                    actionStrings = {'Add','Remove','Update'};
                    title(sprintf('%d - %s',iteration,actionStrings{actionInd}))
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
                    if Obj.LearningText
                        fprintf('Exiting...Precisions no longer changing appreciably.\n');
                    end
                    break;
                end
            end
            
            
            if Obj.LearningText && iteration == Obj.LearningMaxIterations
                fprintf('Exiting...Convergence not reached before the maximum allowed iterations was reached.\n');
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = trainedKernels(relevantIndices);
        end
    end
end