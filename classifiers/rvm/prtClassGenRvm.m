function PrtRvm = prtClassGenRvm(DS,Options)
%PrtRvm = prtClassGenRvm(DS,Options)

if nargin == 1
    Options = prtClassOptRvm;
end

if ~DS.isBinary
    error('prtClassGenRvm requires binary data set');
end

y = DS.getTargets;
y(y == 0) = -1;   %req'd for algorithm

x = DS.getObservations;
[gramm,nBasis] = prtKernelGrammMatrix(x,x,Options.kernel);

PrtRvm.nBasis = nBasis; %this can be used in plotting or for backing out which kernel corresponds to which element of w
PrtRvm.converged = 0;
PrtRvm.PrtDataSet = DS;
PrtRvm.PrtOptions = Options;

theta = ones(size(gramm,2),1);
w = zeros(size(theta));
deltaThetaNorm = ones(Options.Laplacian.maxIterations,1)*nan;

for iteration = 1:Options.Laplacian.maxIterations

    %%%%
    %%See: Herbrich: Learning Kernel Classifiers, Algorithm 7, Page 328
    %%%%

    %check tolerance for basis removal
    relevantIndices = find(theta > Options.Laplacian.thetaTol);
    
    w(setdiff(1:length(w),relevantIndices)) = 0;

    relevantGramm = gramm(:,relevantIndices);
    relevantTheta = theta(relevantIndices);
    relevantThetaInv = diag(1./relevantTheta);
    t = relevantGramm*w(relevantIndices);

    j = y'*t - log(1+exp(t))'*ones(size(t)) - 1/2 * w(relevantIndices)'*relevantThetaInv*w(relevantIndices);

    g = inf;
    
    %this is all gradient ascent for the logistic over the kernel space;
    %we can actually do this in logistic-discriminant I believe
    while norm(g) / length(relevantIndices) > Options.Laplacian.gNorm
        pi = 1./(1 + exp(-t));
        
        g = relevantGramm' * (1/2*(y + 1) - pi) - relevantThetaInv*w(relevantIndices);
        h = -(relevantGramm' * diag(pi.*(1-pi)) * relevantGramm + relevantThetaInv);

        delta = h^-1*g;

        eta = 1;
        jTilde = j - 1;
        
        wTilde = zeros(size(w));
        while jTilde < j
            wTilde(relevantIndices) = w(relevantIndices) - eta*delta;
            tTilde = relevantGramm*wTilde(relevantIndices);
        
            jTilde = y'*tTilde - log(1+exp(tTilde))'*ones(size(tTilde)) - 1/2 * wTilde(relevantIndices)'*relevantThetaInv*wTilde(relevantIndices);

            eta = eta/2;
        end

        w = wTilde;
        j = jTilde;
        t = tTilde;
    end
    
    sigma = -h^-1;
    zeta = ones(size(diag(relevantThetaInv))) - diag(relevantThetaInv).*diag(sigma);

    prevTheta = theta;
    theta(relevantIndices) = w(relevantIndices).^2./zeta;

    deltaThetaNorm(iteration) = norm(prevTheta-theta)./norm(theta);

    if deltaThetaNorm(iteration) < Options.Laplacian.deltaThetaNormTol
        PrtRvm.converged = 1;
        break
    end
end

PrtRvm.Beta = w;
