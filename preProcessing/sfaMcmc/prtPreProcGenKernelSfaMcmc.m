function SFA = prtPreProcGenKernelSfaMcmc(DataSet,Options,AA) %#ok<INUSL>
%SFA = generateSFA(X,Y,Options)
%   generateSFA - Uses MCMC samplig to generate a Sparse Factor Analysis
%   solution.
%

% Code by: Peter Torrione
% Based on: Bo Chen, et al. "Nonparametric Bayesian Factor Analysis: Application to
% Time-Evolving Viral Gene-Expression Data".

SFA.PrtDataSet = DataSet;
X = DataSet.getObservations;

%de-mean X
SFA.mu = mean(X);
SFA.stdev = std(X);
X = bsxfun(@minus,X,SFA.mu);
%X = bsxfun(@rdivide,X,SFA.stdev);

X = X';
[p,n] = size(X);

%Gamma priors:
c = Options.Prior.c;
d = Options.Prior.d;
e = Options.Prior.e;
f = Options.Prior.f;
g = Options.Prior.g;
h = Options.Prior.h;

%Beta priors:
alpha = Options.Prior.alpha;
beta = Options.Prior.beta;
K = Options.maxComponents;

%initial draws from priors, before data:
gamma = ones(p,K);      %gamrnd(c,1./d,p,K);
%pi = ones(K,1)*.01;     %betarnd(alpha/K,beta*(K-1)/K,K,1);
pi = betarnd(alpha/K,beta*(K-1)/K,K,1);

delta = 1;              %gamrnd(e,1./f);
psi = ones(p,1);        %gamrnd(g,1./h,p,1);

pr1 = zeros(K,n);
pr0 = zeros(K,n);

kVec = prtKernelVoigt((1:size(X,1))',size(X,1)/2,2,2);
fn = @(x)imfilter(x,kVec);


[pcScores, A] = hdpca(X',K);

for i = 1:size(A,2)
    disp(i)
    [yHat,Gamma,Alpha] = basicMatchingPursuits((1:size(A,1))',A(:,i),{@(x,y)prtKernelVoigt(x,y,2,2)},5);
    A(:,i) = zeros(size(A(:,i)));
    A(Gamma,i) = Alpha;
end
pcScores = X'*fn(A);
s = pcScores';
% s = pcScores';
z = ones(K,n);

maxIters = Options.Mcmc.nBurin + Options.Mcmc.nSamples;

for iterInd = 1:maxIters
    
    tic;
    %(1) sample each element of the binary matrix z
    zs = z.*s;
    aFiltered = fn(A);
    for k = 1:K
        cL = [1:k-1,k+1:K];
        
        ApA = (aFiltered(:,k).*psi)'* aFiltered(:,k);
        Ap = (aFiltered(:,k).*psi)';
        
        %Added FN:
        xik = X - aFiltered(:,cL)*zs(cL,:);
        
        pr1(k,:) = log(pi(k) + eps) - 1/2 * (ApA * s(k,:).^2 - 2 * Ap * xik .* s(k,:));
        pr0(k,:) = log(1-pi(k) + eps);
    end
    
    ePr1 = exp(pr1);
    ePr1(ePr1 > Options.maxPr) = Options.maxPr;
    ePr0 = exp(pr0);
    ePr0(ePr0 > Options.maxPr) = Options.maxPr;
    pr = ePr1./(ePr1 + ePr0);
    z = double(rand(size(pr)) < pr);
    
    %(2) sample pi_{k}
    for k = 1:K
        alphaPrime = sum(z(k,:)) + alpha/K;
        betaPrime = n - sum(z(k,:)) + beta*(K-1)/K;
        pi(k) = betarnd(alphaPrime,betaPrime);
    end
    
    %(3) sample A
    Aold = A;
    zs = z.*s;
    for k = 1:K
        cL = [1:k-1,k+1:K];
        
        aFiltered = fn(A(:,cL));
        
        %Added FN:
        xji_k = X - aFiltered * zs(cL,:);
        %xji_k = X - A(:,cL) * zs(cL,:);
        
        sigma_jk = (sum(bsxfun(@times,psi(:),s(k,:).^2.*z(k,:).^2),2) + gamma(:,k)).^-1;
        mu_jk = sigma_jk .* sum(bsxfun(@times,psi(:),bsxfun(@times,s(k,:).*z(k,:),xji_k)),2);
        A(:,k) = normrnd(mu_jk,sqrt(sigma_jk));
        
        [yHat,Gamma,Alpha] = basicMatchingPursuits((1:size(A,1))',A(:,k),{@(x,y)prtKernelVoigt(x,y,2,2)},5);
        A(:,k) = zeros(size(A(:,k)));
        A(Gamma,k) = Alpha;
    end
    
    
    %(4) sample s
    warning off; %#ok<WNOFF>
    aKernel = fn(A);
    for i = 1:n
        Az = aKernel;
        Az(:,~logical(z(:,i))) = 0;
        AzPsi = bsxfun(@times,Az,psi);
        
        DeltaInv = (AzPsi'*Az + delta*eye(K));
        Delta = DeltaInv^-1;
        
        %Added FN:
        Chsi = Delta*AzPsi'*X(:,i);
        
        Delta = (Delta + Delta')./2;
        s(:,i) = mvnrnd(Chsi,Delta);
    end
    warning on; %#ok<WNON>
    
    %(5) sample psi
    Afiltered = fn(A);
    for j = 1:p
        gPrime = g + n/2;
        %Added FN:
        hSum = sum((X(j,:) - Afiltered(j,:)*(z.*s)).^2);
        hPrime = h + 1/2*hSum;
        psi(j) = gamrnd(gPrime,1./hPrime);
    end
    
    %(6) Sample gamma
    gamma = gamrnd(c + 1/2, 1./ (d + 1/2.*A.^2));
    
    %(7) Sample delta
    delta = gamrnd(e + n*K/2, 1./ (f + 1/2*sum(diag(s'*s))));
    
    %Handle MCMC estimation using post-burnin nSamples
    if iterInd >= Options.Mcmc.nBurin
        if iterInd == Options.Mcmc.nBurin
            SFA.A = A./Options.Mcmc.nSamples;
            SFA.pi = pi./Options.Mcmc.nSamples;
        else
            SFA.A = SFA.A + A./Options.Mcmc.nSamples;
            SFA.pi = SFA.pi + pi./Options.Mcmc.nSamples;
        end
    end
    
    %Visualize the results at current time
    if ~mod(iterInd,Options.displayOnIter)
        subplot(3,2,1);
        imagesc(z);
        title('Indian Buffet Process');
        tickoff;
        xlabel('customers'); ylabel('dishes');
        subplot(3,2,2);
        stem(pi);
        title('\pi_{k}');
        ylim([0 1]);
        subplot(3,2,3:4);
        [vals,inds] = sort(pi);
        plot(A(:,inds(1:3)));
        hold off
        %ylim([-1 1]);
        title(sprintf('Factors; Iteration %d',iterInd));
        subplot(3,2,5:6);
        imagesc(zs);
        title(sprintf('Scores; Iteration %d',iterInd));
        drawnow;
    end
    toc;
end

sparseSubSet = find(SFA.pi > Options.piThreshold);
SFA.Afull = SFA.A;
SFA.piFull = SFA.pi;
try
    SFA.A = SFA.A(:,sparseSubSet);
    SFA.pi = SFA.pi(sparseSubSet);
catch
    SFA.A = [];
    SFA.pi = [];
end