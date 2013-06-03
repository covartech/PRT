classdef prtClassLogisticDiscriminant < prtClass & prtClassBig
    % prtClassLogisticDiscriminant  Logistic Discriminant classifier
    %
    %    CLASSIFIER = prtClassLogisticDiscriminant returns a LogisticDiscriminant classifier
    %
    %    CLASSIFIER = prtClassLogisticDiscriminant(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassLogisticDiscriminant object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassLogisticDiscriminant object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %   wTolerance       - The convergance tolerance of the weights
    %   irlsStepSize     - Step size used in training. Can be set to a
    %                      double, or 'hessian'. If 'hessian', IRLS is 
    %                      solved using the Hessian to estimate steps.
    %   maxIter          - maximum IRLS iterations
    %   nIterations      - number of iterations used, set during training
    %   wInitTechnique   - Technique to initialize weights, can be set to
    %                      'FLD', 'randn', and 'manual'
    %   manualInitialW   - The values the weights are initialized to if 
    %                      wInitTechnique is set to 'manual'
    %   wTolerance       - Convergence tolerance on weight vector 
    %   handleNonPosDefR - What to do when R is non-positive definte, can
    %                      be set to 'regularize' or 'exit'. When set to 
    %                      regularize, the classifier will attempt to
    %                      regularize the matrix. When set to exit the 
    %                      classifier will exit.
    %
    %   w                - The regression weights, estimated during training
    %                      w(1) corresponds to the DC bias and w(2:end)
    %                      corresponds to the weights for the features
    %
    %    For more information on LogisticDiscriminant classifiers, refer to the
    %    following URL:
    %  
    %    http://en.wikipedia.org/wiki/Logistic_regression
    %
    %    A prtClassLogisticDiscriminant object inherits the TRAIN, RUN, 
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits 
    %    the PLOT method from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUnimodal;           % Create some test and
    %     TrainingDataSet = prtDataGenUnimodal;       % training data
    %     classifier = prtClassLogisticDiscriminant;  % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);       % Train
    %     classified = run(classifier, TestDataSet);            % Test
    %     subplot(2,1,1);
    %     classifier.plot;
    %     subplot(2,1,2);
    %     [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %     h = plot(pf,pd,'linewidth',3);
    %     title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll,
    %    prtClassDlrt, prtClassPlsda, prtClassFld, prtClassRvm,
    %    prtClassLogisticDiscriminant,  prtClass

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


    
    properties (SetAccess=private)
        name = 'Logistic Discriminant'  % Logistic Discriminant
     
        nameAbbreviation = 'LogDisc'  % LogDisc
     
        isNativeMary = false;  % True
    end
    
    % properties (SetAccess = protected)
    properties
        % w  
        %   w is a DataSet.nDimensions + 1 x 1 vector of projection weights
        %   learned during LogDisc.train(DataSet)
        
        w = [];  % Regression weights
        
        % nIterations
        %   Number of iterations used in training.  This is set to a number
        %   between 1 and maxIter during training.
        
        nIterations = nan;  % The number of iterations used in training
        
        wPriorSigma = nan;  % Prior standard deviation on weight vector, use NAN to implement maximum likelihood estimates
    end
    properties
        % irlsStepSize 
        %   irlsStepSize can be the string 'hessian', or a double value
        %   (typically << 1).  If irlsStepSize is 'hessian', IRLS is solved
        %   using the Hessian to estimate steps.  This can be numerically
        %   unstable.  Otherwise, training takes steps in the direction of 
        %   the gradient with a step size of irlsStepSize*gradient.  Default
        %   value is 0.05.
        
        irlsStepSize = .05; % The stepsize

        % maxIter
        %   Maximum number of iterations to allow before exiting without
        %   convergence.
        
        maxIter = 500;  % Maxmimuum number of iterations
        
        
        % wInitTechnique 
        %   wInitTechnique specifies how training should initialize the w
        %   vector.  Possible values are 'FLD', 'randn', and 'manual'.
        
        wInitTechnique = 'FLD';  % Weight initialization technique
        
        % manualInitialW
        %   manualInitialW is used to set the initial w value when
        %   wInitTechnique is 'manual'.  manualInitialW must be a vector
        %   and of length(TrainDataSet.nDimensions + 1)
        
        manualInitialW = []; % The value of the initial weights if initialized manually
        
        % wTolerance
        %   Convergence tolerance on w.  When norm(w - wOld) < wTolerance,
        %   convergence is reached, and training exits.
        
        wTolerance = 1e-2;  % The convergance tolerance of the weights
        
        % handleNonPosDefR
        %   It is possible to obtain non-positive definite re-weighted
        %   least-squares matrices in the optimization process.  Often this
        %   indicates convergence.  handleNonPosDefR can be one of 'exit'
        %   or 'regularize'.  'exit' tells training to exit with the
        %   current weight vector, and 'regularize' attempts to
        %   diagonal-load the R matrix to acheive a well conditioned
        %   matrix.  Often regularizing is a losing battle.
        
        handleNonPosDefR = 'exit';  % The action taken when R is non-positive definite
        
        sgdPassesThroughTheData = 10;
        sgdLearningRate = @(t)((sqrt(t) + 10).^(-0.9));
        sgdRegularization = 0.1;
        sgdWeightTolerance = 1e-6;
        
    end
    
    methods
        
        function Obj = prtClassLogisticDiscriminant(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.irlsStepSize(Obj,val)
            if ~prtUtilIsPositiveScalar(val) && ~strcmpi(val,'hessian')
                error('prt:prtClassLogisticDiscriminant:irlsStepSize','irlsStepSize must be a positive scalar (or the string ''hessian'')');
            end
            Obj.irlsStepSize = val;
        end

        function Obj = set.maxIter(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassLogisticDiscriminant:maxIter','maxIter must be a positive scalar integer');
            end
            Obj.maxIter = val;
        end

        function Obj = set.wInitTechnique(Obj,val)
            if ~isa(val,'char') || ~any(strcmpi(val,{'fld','randn','manual'}))
                error('prt:prtClassLogisticDiscriminant:wInitTechnique','wInitTechnique must be a string matching one of ''fld'', ''randn'', or ''manual''');
            end
            Obj.wInitTechnique = val;
        end

        function Obj = set.manualInitialW(Obj,val)
            if ~isnumeric(val) && ~isvector(val) && ~isempty(val)
                error('prt:prtClassLogisticDiscriminant:manualInitialW','manualInitialW must be a numeric vector');
            end
            Obj.manualInitialW = val;
        end

        function Obj = set.wTolerance(Obj,val)
            if ~prtUtilIsPositiveScalar(val)
                error('prt:prtClassLogisticDiscriminant:wTolerance','wTolerance must be a positive scalar');
            end
            Obj.wTolerance = val;
        end

        function Obj = set.handleNonPosDefR(Obj,val)
            if ~isa(val,'char') || ~any(strcmpi(val,{'exit','regularize'}))
                error('prt:prtClassLogisticDiscriminant:handleNonPosDefR','handleNonPosDefR must be a string matching one of ''exit'' or ''regularize''');
            end
            Obj.handleNonPosDefR = val;
        end

    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            %Obj = trainAction(Obj,DataSet)
            
            
            if ~DataSet.isBinary
                error('prtClassLogisticDiscriminant:nonBinaryTraining','Input dataSet for prtClassLogisticDiscriminant.train must be binary');
            end
            
            %Helper functions:
            sigmaFn = @(x) 1./(1 + exp(-x));
            rCondDiag = @(vec) min(vec)/max(vec);
            
            switch lower(Obj.wInitTechnique)
                case 'fld'
                    Fld = prtClassFld;
                    Fld = Fld.train(DataSet);
                    Obj.w = [1;Fld.w]; %append zero for offset
                case 'randn'
                    Obj.w = randn(DataSet.nFeatures+1,1);
                case 'manual'
                    assert(isvector(Obj.manualInitialW) & numel(Obj.manualInitialW) == DataSet.nFeatures + 1,'manualInitialW must be a vector and have %d elements',DataSet.nFeatures + 1);
                    assert(isequal(size(Obj.manualInitialW), [DataSet.nFeatures + 1,1]), 'manualInitialW must be a %d x 1 vector',DataSet.nFeatures + 1);
                    Obj.w = Obj.manualInitialW;
                otherwise
                    error('Invalid value for Options.wInitTechnique; wInitTechnique must be one of {''FLD'',''randn'',''manual''}');
            end
            
            DataSet = DataSet.retainLabeled; % Only use labeled data to train
            
            x = DataSet.getObservations;
            x = cat(2,ones(size(x,1),1),x);  %append "ones"
            %             y = DataSet.getTargets;
            %             if ~isequal(DataSet.uniqueClasses,[0;1])
            %                 bm = DataSet.getTargetsAsBinaryMatrix;
            %                 y(logical(bm(:,1))) = 0;
            %                 y(logical(bm(:,2))) = 1;
            %             end
            y = DataSet.getBinaryTargetsAsZeroOne;
            
            yOut = sigmaFn((x*Obj.w)')';
            rVec = yOut.*(1-yOut);
            
            converged = 0;
            nIter = 1;
            
            while ~converged
                Obj.nIterations = nIter;
                
                %these next lines are for numerical instabilities; these are detected
                %using the rCond of rVec or any nans in rVec
                if rCondDiag(rVec) < eps*2 || any(isnan(rVec))
                    %Numerical instability options are normalize, exit, or stepsize.
                    switch lower(Obj.handleNonPosDefR)
                        case 'regularize'
                            warning('prt:generateLogDisc:stepSize','rcond(R) < eps; attempting to diagonally load R');
                            diagAdd = 1e-5*max(rVec);
                            while(rCondDiag(rVec) < eps*2)
                                rVec = rVec + diagAdd;
                            end
                        case 'exit'
                            warning('prt:generateLogDisc:stepSize','rcond(R) < eps; Exiting; Try reducing classifier.irlsStepSize');
                            return;
                        otherwise
                            error('Invalid Obj.handleNonPosDefR field');
                    end
                end
                if isnan(Obj.wPriorSigma)
                    priorSigma = inf;
                else
                    priorSigma = Obj.wPriorSigma;
                end
                if isa(Obj.irlsStepSize,'char') && strcmpi(Obj.irlsStepSize,'hessian')
                    % Bishop equations:
                    %         wOld = w;
                    %         z = x*wOld - (R^-1)*(yOut - y);
                    %         w = (x'*R*x)^-1*x'*R*z;
                    %         %re-calculate yOut and R
                    %         yOut = sigmaFn((x*w)')';
                    %         R = diag(yOut.*(1-yOut));
                    
                    %Non-matrix R Bishop equations (memory saving equations):
                    wOld = Obj.w;
                    z = x*wOld - bsxfun(@times,rVec.^-1,(yOut - y));
                    Obj.w = (x'*bsxfun(@times,rVec,x) + eye(size(x,2))*1./priorSigma)^-1*x'*bsxfun(@times,rVec,z);
                    %re-calculate yOut and R
                    yOut = sigmaFn((x*Obj.w)')';
                    rVec = yOut.*(1-yOut);
                elseif isa(Obj.irlsStepSize,'char')
                    error('String irlsStepSize must be ''hessian''');
                elseif isa(Obj.irlsStepSize,'double')
                    % Raw update equations:
                    %         wOld = w;
                    %         H = x'*R*x;
                    %         dE = x'*(yOut - y);
                    %         w = w - H^-1*dE*Options.irlsStepSize;  %move by stepsize * the hessian
                    %         %re-calculate yOut and R
                    %         yOut = sigmaFn((x*w)')';
                    %         R = diag(yOut.*(1-yOut));
                    
                    %Non-matrix R Raw equations (memory saving equations):
                    wOld = Obj.w;
                    H = x'*bsxfun(@times,rVec,x) + eye(size(x,2))*1./priorSigma;

                    if rcond(H) < eps
                        warning('prt:generateLogDisc:stepSize','rcond(H) < eps; Exiting; Try reducing Options.irlsStepSize');
                        return;
                    end
                    
                    dE = x'*(yOut - y);
                    Obj.w = Obj.w - H^-1*dE*Obj.irlsStepSize;  %move by stepsize * the hessian
                    %re-calculate yOut and R
                    yOut = sigmaFn((x*Obj.w)')';
                    rVec = yOut.*(1-yOut);
                end
                
                if norm(Obj.w - wOld) < Obj.wTolerance
                    converged = 1;
                end
                
                if nIter > Obj.maxIter
                    warning('prt:generateLogDisc:maxIter',sprintf('nIterations (%d) > maxIterations; exiting',nIter)); %#ok
                    return;
                end
                nIter = nIter + 1;
            end
        end
        
        function self = trainActionBig(self,ds)
            
            nTriesForNonEmptyBlock = 1000;
            useVariableLearningRate = isa(self.sgdLearningRate,'function_handle');
            converged = false;
            
            nMaxIterations = self.sgdPassesThroughTheData*ds.getNumBlocks();
            
            for iter = 1:nMaxIterations
                
                % Try to load a block
                for blockLoadTry = 1:nTriesForNonEmptyBlock
                    cBlockDs = ds.getRandomBlock;
                    if ~isempty(cBlockDs)
                        break
                    end
                end
                if blockLoadTry == nTriesForNonEmptyBlock
                    warning('Exiting after %d empty blocks were consecutlivly found.', nTriesForNonEmptyBlock);
                    break
                end
                
                % cBlockDs is now our dataset
                
                if iter==1
                    cW = zeros(cBlockDs.nFeatures+1,1);
                    wOld = inf;
                    
                end
                cX = cat(2,ones(cBlockDs.nObservations,1), cBlockDs.X);
                
                % Get Y as -1, 1
                cY = cBlockDs.getTargetsAsBinaryMatrix;
                cY = cY(:,end); % In case of m-ary data we also do the last one.
                cY(cY == 0) = -1;
                
                %cW = cW + self.irlsStepSize*sum(bsxfun(@times,cY./(1 + exp(cY.*(cX*cW))),cX),1)';
                
                if useVariableLearningRate
                    cLearningRate = self.sgdLearningRate(iter);
                else
                    cLearningRate = self.sgdLearningRate;
                end
                cStep = (self.sgdRegularization*cW - mean(bsxfun(@times,cY./(1 + exp(cY.*(cX*cW))),cX),1)');
                cW = cW - cLearningRate*cStep;
                
                %cW = cW - cLearningRate*G^(-1/2)*cStep;
                cChange = norm(cW - wOld)/norm(cW);
                if cChange < self.sgdWeightTolerance
                    converged = true;
                    break
                end
                
                wOld = cW;
                
                plotOnIter = 1;
                if plotOnIter && ~mod(iter,plotOnIter)
                    plot(cW)
                    title(sprintf('iteration=%d - change=%0.3f',iter,cChange));
                    drawnow;
                end
            end
            
            if ~converged
                warning('prt:prtClassLogisticDiscriminant:notConverged','Convergence was not reached in the maximum number of allowed iterations.');
            end
            
            self.w = cW;
        end
        
        function ds = runAction(self,ds)
            ds.X = runFast(self,ds.X);
        end
        
        function y = runActionFast(self, x)
            x = cat(2,ones(size(x,1),1),x);
            y = 1./(1 + exp(-((x*self.w)')'));
        end
    end
end
