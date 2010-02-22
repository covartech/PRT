function PrtClassMap = prtClassGenMap(PrtDataSet,PrtClassOpt)
%PrtClassMap = prtClassGenMap(PrtDataSet,PrtClassOpt)

PrtClassMap.PrtDataSet = PrtDataSet;
PrtClassMap.PrtOptions = PrtClassOpt;

PrtClassMap.rvs = repmat(PrtClassMap.PrtOptions.rvs(:), (PrtClassMap.PrtDataSet.nClasses - length(PrtClassMap.PrtOptions.rvs)+1),1);
PrtClassMap.rvs = PrtClassMap.rvs(1:PrtClassMap.PrtDataSet.nClasses);

for iY = 1:PrtDataSet.nClasses
    PrtClassMap.rvs(iY) = mle(PrtClassMap.rvs(iY), PrtDataSet.getObservationsByClassInd(iY));
end