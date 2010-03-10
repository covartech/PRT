function ClassifierResults = prtClassRunMap(PrtClassMap,PrtDataSet)
% ClassifierResults = prtClassRunMap(PrtClassMap,PrtDataSet)

logLikelihoods = zeros(PrtDataSet.nObservations, length(PrtClassMap.rvs));

for iY = 1:length(PrtClassMap.rvs)
    logLikelihoods(:,iY) = logPdf(PrtClassMap.rvs(iY), PrtDataSet.getObservations());
end

% Change to posterior probabilities and package everything up in a
% prtDataSet
ClassifierResults = prtDataSet(exp(bsxfun(@minus, logLikelihoods, prtUtilSumExp(logLikelihoods.').')));
ClassifierResults.UserData.logLikelihoods = logLikelihoods;