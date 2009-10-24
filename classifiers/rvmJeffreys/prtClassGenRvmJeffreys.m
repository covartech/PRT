function Rvm = prtClassGenRvmJeffreys(DS,PrtOptions)
%Rvm = prtClassGenRvmJeffreys(DS,PrtOptions)

warningState = warning;
warning off MATLAB:nearlySingularMatrix

if nargin == 1
    PrtOptions.maxIterations = 1000;
end

if ~DS.isBinary
    error('prtClassGenRvm requires binary data set');
end

y = DS.getTargets;
y(y == 0) = -1;     %req'd for algorithm

x = DS.data;
[gramm,nBasis] = prtKernelGrammMatrix(x,x,PrtOptions.kernel);

nBasis = sum(nBasis);

sigmaSquared = eps;
beta = (sigmaSquared*eye(nBasis) + gramm'*gramm)\gramm'*y;
u = diag(abs(beta));
relevantIndices = 1:size(gramm,2);

h1Ind = y == 1;
h0Ind = y == -1;
for iteration = 1:PrtOptions.Jeffereys.maxIterations
    
    %%%%
    %%See: Figueiredo: "Adaptive Sparseness For Supervised Learning"
    %%%%
    uK = u(relevantIndices,relevantIndices);
    grammK = gramm(:,relevantIndices);
    
    S = gramm*beta;
    S(h1Ind) = S(h1Ind) + normpdf(S(h1Ind))./(1-normcdf(-S(h1Ind)));
    S(h0Ind) = S(h0Ind) - normpdf(S(h0Ind))./(normcdf(-S(h0Ind)));
    
    beta_OLD = beta;
    
    A = (eye(size(uK)) + uK*grammK'*grammK*uK);
    B = uK*(grammK'*y);   %this is correct
    
    beta(relevantIndices,1) = uK*(A\B);
    
    %
    relevantIndices = find(abs(beta) > max(abs(beta))*PrtOptions.Jeffereys.betaRelevantTolerance);
    irrelevantIndices = abs(beta) <= max(abs(beta))*PrtOptions.Jeffereys.betaRelevantTolerance;
    beta(irrelevantIndices,1) = 0;
    u = diag(abs(beta));

    %check tolerance for basis removal
    TOL = norm(beta-beta_OLD)/norm(beta_OLD);
    if TOL < PrtOptions.Jeffereys.betaConvergedTolerance
        Rvm.converged = true;
        break;
    end
end

Rvm.PrtOptions = PrtOptions;
Rvm.PrtDataSet = DS;
Rvm.Beta = beta;
warning(warningState);