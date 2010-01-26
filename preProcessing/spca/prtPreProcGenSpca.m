function SPCA = prtPreProcGenSpca(PrtDataSet,Options)
%	prtPreProcGenerateSpca Generates a sparse principal components regression
%

X = PrtDataSet.getObservations;

SPCA.PrtOptions = Options;
SPCA.mu = mean(X);
X = bsxfun(@minus,X,SPCA.mu);

%Step 1, page 272
[U,S,V] = svd(X,'econ');
A = V(:,1:Options.nComponents);

B = zeros(size(A));
normDiff = zeros(1,Options.nComponents);
prevB = B;

SPCA.converged = false;
for iter = 1:Options.maxIter
    
    %Step 2*, page 274
    for k = 1:Options.nComponents
        B(:,k) = softThreshold(A(:,k)'*X'*X,Options.lambda);
    end    
    %Step 3, page 272
    [U,S,V] = svd((X'*(X*B)),'econ');
    A = U(:,1:Options.nComponents)*V;
    
    %check convergence
    for k = 1:Options.nComponents
        normDiff(k) = norm(B(:,k) - prevB(:,k))./norm(B(:,k));
    end
    if all(normDiff < Options.Convergence.normPercentThreshold)
        SPCA.converged = true;
        break;
    end
    prevB = B;
    
    %Display, if asked
    if ~mod(iter,Options.Display.plotOnIter);
        Bplot = B;
        for k = 1:Options.nComponents
            Bplot(:,k) = Bplot(:,k)./norm(Bplot(:,k));
        end
        subplot(2,1,1); plot(Bplot);
        subplot(2,1,2); dprtDataPlot(X*B);
        title(iter);
        drawnow;
        disp(normDiff);
    end

end

%Step 5, Normalize
for k = 1:Options.nComponents
    B(:,k) = B(:,k)./norm(B(:,k));
end
SPCA.B = B;
return;

function [B,threshInd] = softThreshold(temp,lambda)
threshInd = abs(temp) < lambda/2;  %these go to zero
B(threshInd) = 0;
B(~threshInd) = (abs(temp(~threshInd)) - lambda/2).*sign(temp(~threshInd));
