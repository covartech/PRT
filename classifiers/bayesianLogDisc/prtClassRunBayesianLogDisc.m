function [ClassifierResults,Etc] = prtClassRunBayesianLogDisc(BLD,PrtDataSet)
%[ClassifierResults,Etc] = prtClassRunBayesianLogDisc(BLD,PrtDataSet)


Etc = [];
x = PrtDataSet.getObservations;
x = cat(2,ones(size(x,1),1),x);

sigmaSquared = zeros(size(x,1),1);
mu = zeros(size(x,1),1);

for i = 1:size(x,1);
    sigmaSquared(i) = x(i,:)*BLD.sMap*x(i,:)';
    mu(i) = BLD.wMap'*x(i,:)';
end

sigmaFn = @(x) 1./(1 + exp(-x));
kappaFn = @(sigmaSquaredVar) (1 + pi*sigmaSquaredVar/8).^(-1/2);

ClassifierResults = prtDataSetClass(sigmaFn(kappaFn(sigmaSquared).*mu));


end