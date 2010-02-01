function LogDisc = prtClassGenLogDisc(DS,Options)
%
%   

LogDisc.PrtDataSet = DS;
LogDisc.PrtOptions = Options;

sigmaFn = @(x) 1./(1 + exp(-x));

switch lower(Options.wInit)
    case 'fld'
        Fld = prtClassGenFld(DS,prtClassOptFld);
        w = [0;Fld.w]; %append zero for offset
    case 'randn'
        w = randn(DS.nFeatures+1,1);
    case 'manual'
        w = Options.initialW;
    otherwise 
        error('Invalid value for Options.wInit; wInit must be one of {''FLD'',''randn'',''manual''}');
end

x = DS.getObservations;
x = cat(2,ones(size(x,1),1),x);
y = DS.getTargets;

yOut = sigmaFn((x*w)')';
rVec = yOut.*(1-yOut);

rCondDiag = @(vec) min(vec)/max(vec);

converged = 0;
iter = 1;
LogDisc.isMary = 0;
while ~converged 
    
    %these next lines are for numerical instabilities; these are detected
    %using the rCond of rVec or any nans in rVec
    if rCondDiag(rVec) < eps*2 || any(isnan(rVec))
        %Numerical instability options are normalize, exit, or stepsize.
        switch lower(Options.handleNonPosDefR)
            case 'regularize'
                warning('dprt:generateLogDisc:stepSize','rcond(R) < eps; attempting to diagonal load R');
                diagAdd = 1e-5*max(rVec);
                while(rCondDiag(rVec) < eps*2)
                    rVec = rVec + diagAdd;
                end
            case 'exit'
                warning('dprt:generateLogDisc:stepSize','rcond(R) < eps; Exiting; Try reducing Options.irlsStepSize');
                
                LogDisc.w = w;
                LogDisc.iter = iter;
                return;
            otherwise
                error('Invalid Options.handleNonPosDefR field');
        end
    end
    
    if isa(Options.irlsStepSize,'char') && strcmpi(Options.irlsStepSize,'hessian')
        % Bishop equations:
        %         wOld = w;
        %         z = x*wOld - (R^-1)*(yOut - y);
        %         w = (x'*R*x)^-1*x'*R*z;
        %         %re-calculate yOut and R
        %         yOut = sigmaFn((x*w)')';
        %         R = diag(yOut.*(1-yOut));
        
        %Non-matrix R Bishop equations (memory saving equations):
        wOld = w;
        z = x*wOld - bsxfun(@times,rVec.^-1,(yOut - y));
        w = (x'*bsxfun(@times,rVec,x))^-1*x'*bsxfun(@times,rVec,z);
        %re-calculate yOut and R
        yOut = sigmaFn((x*w)')';
        rVec = yOut.*(1-yOut);
    elseif isa(Options.irlsStepSize,'char')
        error('String irlsStepSize must be ''hessian''');
    elseif isa(Options.irlsStepSize,'double')
        % Raw update equations:
        %         wOld = w;
        %         H = x'*R*x;
        %         dE = x'*(yOut - y);
        %         w = w - H^-1*dE*Options.irlsStepSize;  %move by stepsize * the hessian
        %         %re-calculate yOut and R
        %         yOut = sigmaFn((x*w)')';
        %         R = diag(yOut.*(1-yOut));
        
        %Non-matrix R Raw equations (memory saving equations):
        wOld = w;
        H = x'*bsxfun(@times,rVec,x);
        
        if rcond(H) < eps
            warning('dprt:generateLogDisc:stepSize','rcond(H) < eps; Exiting; Try reducing Options.irlsStepSize');
            LogDisc.w = w;
            LogDisc.iter = iter;
            return;
        end
        
        dE = x'*(yOut - y);
        w = w - H^-1*dE*Options.irlsStepSize;  %move by stepsize * the hessian
        %re-calculate yOut and R
        yOut = sigmaFn((x*w)')';
        rVec = yOut.*(1-yOut);
    end

    LogDisc.w = w;
    LogDisc.iter = iter;

    if norm(w - wOld) < Options.wTolerance
        converged = 1;
    end

    if iter > Options.maxIter
        warning('dprt:generateLogDisc:maxIter',sprintf('nIterations (%d) > maxIterations; exiting',iter)); %#ok
        return;
    end
    iter = iter + 1;
end
