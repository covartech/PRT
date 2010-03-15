function Gp = prtRegGenGp(PrtDataSet,PrtOptions)
%Gp = prtRegGenGp(PrtDataSet,PrtOptions)

Gp.CN = feval(PrtOptions.covarianceFunction, PrtDataSet.getObservations(), PrtDataSet.getObservations()) + PrtOptions.noiseVariance*eye(PrtDataSet.nObservations);

Gp.weights = Gp.CN\PrtDataSet.getTargets(); 

Gp.PrtDataSet = PrtDataSet;
Gp.covarianceFunction = PrtOptions.covarianceFunction;
Gp.noiseVariance = PrtOptions.noiseVariance;