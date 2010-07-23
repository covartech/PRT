classdef prtClassLogisticDiscriminant < prtClass
    % prtClassLogisticDiscriminant - Logistic discriminant classification
    % object.
    %
    % prtClassLogisticDiscriminant Properties: 
    %   w - regression weights - estimated during training
    %   irlsStepSize - Step size used in training
    %   maxIter - maximum IRLS iterations
    %   nIterations - number of iterations used (set during training)
    %   wInitTechnique - Technique to initialize weights
    %   wTolerance - Convergence tolerance on weight vector 
    %   handleNonPosDefR - How to handle non positive definite matrix R
    %
    % prtClassLogisticDiscriminant Methods:
    %   prtClassLogisticDiscriminant - Logistic Discrminant constructor
    %   train - Logistic discriminant training; see prtAction.train
    %   run - Logistic discriminant evaluation; see prtAction.run
    %   
    
    properties (SetAccess=private)
        % name
        %   String value, required by prtAction
        name = 'Logistic Discriminant'
        % nameAbbreviation
        %   String value, required by prtAction
        nameAbbreviation = 'LogDisc'
        % isSupervised
        %   Boolean value, required by prtAction
        isSupervised = true;
        
        % isNativeMary
        %   Boolean value, required by prtClass
        isNativeMary = false;
    end
    
    properties
        % w  
        %   w is a DataSet.nDimensions + 1 x 1 vector of projection weights
        %   learned during LogDisc.train(DataSet)
        w = [];
        
        % irlsStepSize 
        %   irlsStepSize can be the string 'hessian', or a double value
        %   (typically << 1).  If irlsStepSize is 'hessian', IRLS is solved
        %   using the Hessian to estimate steps.  This can be numerically
        %   unstable.  Otherwise, training takes steps in the direction of 
        %   the gradient with a step size of irlsStepSize*gradient.  Default
        %   value is 0.05.
        irlsStepSize = .05; %'hessian'

        % maxIter
        %   Maximum number of iterations to allow before exiting without
        %   convergence.
        maxIter = 500;
        
        % nIterations
        %   Number of iterations used in training.  This is set to a number
        %   between 1 and maxIter during training.
        nIterations = nan;
        
        % wInitTechnique 
        %   wInitTechnique specifies how training should initialize the w
        %   vector.  Possible values are 'FLD', 'randn', and 'manual'.
        wInitTechnique = 'FLD';
        
        % manualInitialW
        %   manualInitialW is used to set the initial w value when
        %   wInitTechnique is 'manual'.  manualInitialW must be a vector
        %   and of length(TrainDataSet.nDimensions + 1)
        manualInitialW = [];
        
        % wTolerance
        %   Convergence tolerance on w.  When norm(w - wOld) < wTolerance,
        %   convergence is reached, and training exits.
        wTolerance = 1e-2;
        
        % handleNonPosDefR
        %   It is possible to obtain non-positive definite re-weighted
        %   least-squares matrices in the optimization process.  Often this
        %   indicates convergence.  handleNonPosDefR can be one of 'exit'
        %   or 'regularize'.  'exit' tells training to exit with the
        %   current weight vector, and 'regularize' attempts to
        %   diagonal-load the R matrix to acheive a well conditioned
        %   matrix.  Often regularizing is a losing battle.
        handleNonPosDefR = 'exit';
    end
    
    methods
        
        function Obj = prtClassLogisticDiscriminant(varargin)
            %LogDisc = prtClassLogisticDiscriminant(varargin)
            %   The Logistic Discriminant constructor allows the user to
            % use name/property pairs to set public fields of the Logistic
            % Discriminant object.
            %
            %   For example:
            %
            %   LogDisc = prtClassLogisticDiscriminant;
            %   LogDiscSmallStep = prtClassLogisticDiscriminant('irlsStepSize',.001);
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected)
        
        function Obj = trainAction(Obj,DataSet)
            %Obj = trainAction(Obj,DataSet)
	
            %Helper functions:
            sigmaFn = @(x) 1./(1 + exp(-x));
            rCondDiag = @(vec) min(vec)/max(vec);
            
            switch lower(Obj.wInitTechnique)
                case 'fld'
                    Fld = prtClassFld;
                    Fld = Fld.train(DataSet);
                    Obj.w = [0;Fld.w]; %append zero for offset
                case 'randn'
                    Obj.w = randn(DataSet.nFeatures+1,1);
                case 'manual'
                    assert(isvector(Obj.manualInitialW) & numel(Obj.manualInitialW) == DataSet.nDimensions + 1,'manualInitialW must be a vector and have %d elements',DataSet.nDimensions + 1);
                    Obj.w = Obj.manualInitialW;
                otherwise
                    error('Invalid value for Options.wInitTechnique; wInitTechnique must be one of {''FLD'',''randn'',''manual''}');
            end
            
            x = DataSet.getObservations;
            x = cat(2,ones(size(x,1),1),x);  %append "ones"
            y = DataSet.getTargets;
            
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
                            warning('prt:generateLogDisc:stepSize','rcond(R) < eps; Exiting; Try reducing Options.irlsStepSize');
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
                        warning('dprt:generateLogDisc:stepSize','rcond(H) < eps; Exiting; Try reducing Options.irlsStepSize');
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
                    warning('dprt:generateLogDisc:maxIter',sprintf('nIterations (%d) > maxIterations; exiting',nIterations)); %#ok
                    return;
                end
                nIter = nIter + 1;
            end

            
        end
        
        function ClassifierResults = runAction(Obj,DataSet)
            %ClassifierResults = runAction(Obj,DataSet)
            
            sigmaFn = @(x) 1./(1 + exp(-x));
            
            x = cat(2,ones(size(DataSet.data,1),1),DataSet.data);
            y = sigmaFn((x*Obj.w)')';
            ClassifierResults = prtDataSetClass(y);
        end
    end
    
end