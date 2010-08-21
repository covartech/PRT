function Regressor = prtRegGenLadIrls(PrtDataSet,PrtOptions)
%Rvm = prtRegGenLadIrls(PrtDataSet,PrtOptions)

X = PrtDataSet.getObservations;
Y = PrtDataSet.getTargets;

Xc = bsxfun(@minus,X,mean(X,1));
Yc = bsxfun(@minus,Y,mean(Y,1));

Beta = (Xc'*Xc)^(-1) * Xc'*Yc;
Beta = [mean(Y,1) - mean(X,1)*Beta;Beta];
Beta = randn(size(Beta)).*[1 1000]'

maxIters = 1000;
errorThreshold = 1e-10;
convergenceThreshold = 1e-6;

X = cat(2,ones(size(X,1),1),X);
for i = 1:maxIters
    %this can be faster; we do not need to build the whole W matrix, since
    %it's purely diagonal
    error = Y - X*Beta;
    error(abs(error) < errorThreshold) = errorThreshold;
    W = diag(1./abs(error));
    
    BetaOld = Beta;
    
    Beta = (X'*W*X)^-1*X'*W*Y;
    Beta = Beta(:);
    
    converged = norm(BetaOld - Beta) < convergenceThreshold;
    if converged
        errorValue = sum(1./error.*(Y - X*Beta).^2)
        Regressor.converged = true;
        Regressor.Beta = Beta;
        Regressor.PrtDataSet = PrtDataSet;
        Regressor.PrtOptions = PrtOptions;
        return;
    end
end

Regressor.converged = false;
Regressor.Beta = Beta;
Regressor.PrtDataSet = PrtDataSet;
Regressor.PrtOptions = PrtOptions;

