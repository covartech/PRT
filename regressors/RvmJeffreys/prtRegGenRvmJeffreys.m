function Rvm = prtRegGenRvmJeffreys(PrtDataSet,PrtOptions)
%Rvm = prtRegGenRvmJeffreys(PrtDataSet,PrtOptions)

Rvm.PrtOptions = PrtOptions;
Rvm.PrtDataSet = PrtDataSet;

n = PrtDataSet.nObservations;
y = PrtDataSet.getTargets;
x = PrtDataSet.getObservations;
[gramm,nBasis] = prtKernelGrammMatrix(x,x,PrtOptions.kernel);

beta = ones(size(gramm,2),1);
U = diag(abs(beta));
I = eye(size(gramm,2));

beta = U*(I + U*(gramm'*gramm)*U)^(-1)*U*gramm'*y;
betaOld = beta;

for iter = 1:PrtOptions.Jeffereys.maxIterations
    
    relInd = find(abs(beta) > eps);
    
    % Without reducing dimensions at each iter:
    %     U = diag(abs(beta));
    %     sigmaSquared = norm(y - gramm*beta).^2./n;
    %     beta = U*(sigmaSquared*I + U*gramm'*gramm*U)^(-1)*U*gramm'*y;
    %     converged = norm(beta - betaOld) < PrtOptions.Jeffereys.betaConvergedTolerance;
    
    % Removing irrelevant indices:
    I = eye(length(relInd));
    U = diag(abs(beta(relInd)));
    locGramm = gramm(:,relInd);
    
    sigmaSquared = norm(y - locGramm*beta(relInd)).^2./n;
    %beta(relInd) = U*(sigmaSquared*I + U*locGramm'*locGramm*U)^(-1)*U*locGramm'*y;    
    beta(relInd) = U*((sigmaSquared*I + U*(locGramm'*locGramm)*U)\(U*locGramm'*y));
    
    plotting = true;
    if plotting
        Rvm.beta = beta;
        Results = prtRun(Rvm,PrtDataSet);
        subplot(2,1,1);
        plot(x,y,x,Results.getObservations); axis tight;
        title(iter);
        subplot(2,1,2);
        plot(beta); axis tight;
        drawnow;
    end
    
    converged = norm(beta - betaOld) < PrtOptions.Jeffereys.betaConvergedTolerance;
    betaOld = beta;
    if converged 
        break
    end
end

Rvm.beta = beta;
Rvm.sigmaSquared = sigmaSquared;