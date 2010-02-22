function [ClassifierResults,Etc] = prtClassRunBayesianLogDisc(BLD,PrtDataSet)
%PrtClassFld = prtClassRunBayesianLogDisc(PrtDataSet,PrtClassOpt)

Etc = [];
x = PrtDataSet.getObservations;
x = cat(2,ones(size(x,1),1),x);

sigma = zeros(size(x,1),1);
mu = zeros(size(x,1),1);

for i = 1:size(x,1);
    sigma(i) = x(i,:)*BLD.sMap*x(i,:)';
    mu(i) = BLD.wMap'*x(i,:)';
end

sigmaFn = @(x) 1./(1 + exp(-x));
kappaFn = @(sigmaSquared) (1 + pi*sigmaSquared/8).^(-1/2);

ClassifierResults = prtDataSet(sigmaFn(kappaFn(sigma.^2).*mu));


end