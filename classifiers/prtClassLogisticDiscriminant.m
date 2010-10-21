classdef prtClassLogisticDiscriminant < prtClass
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
    %   w                - The regression weights, estimated during training
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
    %    For more information on LogisticDiscriminant classifiers, refer to the
    %    following URL:
    %  
    %    XXX Need ref
    %
    %    A prtClassLogisticDiscriminant object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;           % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;       % training data
    %     classifier = prtClassLogisticDiscriminant;  % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);       % Train
    %     classified = run(classifier, TestDataSet);            % Test
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll,
    %    prtClassDlrt, prtClassPlsda, prtClassFld, prtClassRvm,
    %    prtClassLogisticDiscriminant,  prtClass
    
    
    properties (SetAccess=private)
        name = 'Logistic Discriminant'  % Logistic Discriminant
     
        nameAbbreviation = 'LogDisc'  % LogDisc
     
        isNativeMary = false;  % True
    end
    
    properties
        % w  
        %   w is a DataSet.nDimensions + 1 x 1 vector of projection weights
        %   learned during LogDisc.train(DataSet)
        
        w = [];  % Regression weights
        
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
        
        % nIterations
        %   Number of iterations used in training.  This is set to a number
        %   between 1 and maxIter during training.
        
        nIterations = nan;  % The number of iterations used in training
        
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
    end
    
    methods
        
        function Obj = prtClassLogisticDiscriminant(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            %Obj = trainAction(Obj,DataSet)
	
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
                    Obj.w = (x'*bsxfun(@times,rVec,x))^-1*x'*bsxfun(@times,rVec,z);
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
                    H = x'*bsxfun(@times,rVec,x);
                    
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
                    warning('prt:generateLogDisc:maxIter',sprintf('nIterations (%d) > maxIterations; exiting',nIterations)); %#ok
                    return;
                end
                nIter = nIter + 1;
            end

            
        end
        
        function ClassifierResults = runAction(Obj,DataSet)
            %ClassifierResults = runAction(Obj,DataSet)
            
            sigmaFn = @(x) 1./(1 + exp(-x));
            
            
            x = cat(2,ones(DataSet.nObservations,1),DataSet.getX());
            y = sigmaFn((x*Obj.w)')';
            ClassifierResults = DataSet.setObservations(y);
        end
    end
    
end