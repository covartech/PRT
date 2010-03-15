function ClassifierResults = prtRegRunGp(Gp,DS)

k = feval(Gp.covarianceFunction, Gp.PrtDataSet.getObservations(), DS.getObservations());

ClassifierResults = prtDataSet(k'*Gp.weights);

c = diag(feval(Gp.covarianceFunction, DS.getObservations(), DS.getObservations())) + Gp.noiseVariance;

ClassifierResults.UserData.variances = c - prtUtilCalcDiagXcInvXT(k', Gp.CN);