function [PCSCORE, COEFF, eigenvalues] = prtUtilPcaHd(X,nFeaturesOut)
%[PCSCORE, COEFF] = prtUtilPcaHd(X,nFeaturesOut)
% Performs PCA along the columns and converts to PCA along the rows. Good for short, fat matrices





if nargin < 2 || isempty(nFeaturesOut)

    nFeaturesOut = size(X,2);
end

N = size(X,1);
[V, L] = eig((1/N)*(X*X'));

[lambda, sortedLInd] = sort(diag(L),'descend');
V = V(:,sortedLInd);

if nFeaturesOut < 1
    percentEnergy = cumsum(lambda)./sum(lambda);
    nFeaturesOut = find(percentEnergy > nFeaturesOut,1,'first');
end

COEFF = zeros(size(X,2),nFeaturesOut);
for iL = 1:nFeaturesOut
    COEFF(:,iL) = 1/((N*lambda(iL))^(1/2))*X'*V(:,iL);
end

eigenvalues = lambda;
PCSCORE =  X*real(COEFF);
