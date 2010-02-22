function [ClassifierResults, Etc] = prtClassRunMap(PrtClassMap,PrtDataSet)
% [ClassifierResults,Etc] = prtClassRunMap(PrtClassMap,PrtDataSet)

Etc.logLikelihoods = zeros(PrtDataSet.nObservations, length(PrtClassMap.rvs));

for iY = 1:length(PrtClassMap.rvs)
    Etc.logLikelihoods(:,iY) = logPdf(PrtClassMap.rvs(iY), PrtDataSet.getObservations());
end

% Change to posterior probabilities and package everything up in a
% prtDataSet
ClassifierResults = prtDataSet(exp(bsxfun(@minus, Etc.logLikelihoods, prtUtilSumExp(Etc.logLikelihoods.').')));