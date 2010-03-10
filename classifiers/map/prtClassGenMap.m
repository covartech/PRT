function PrtClassMap = prtClassGenMap(PrtDataSet,PrtClassOpt)
%PrtClassMap = prtClassGenMap(PrtDataSet,PrtClassOpt)

% Repmat the rv objects to get one for each class
PrtClassMap.rvs = repmat(PrtClassOpt.rvs(:), (PrtDataSet.nClasses - length(PrtClassOpt.rvs)+1),1);
PrtClassMap.rvs = PrtClassMap.rvs(1:PrtDataSet.nClasses);

% Get the ML estimates of the RV parameters for each class
for iY = 1:PrtDataSet.nClasses
    PrtClassMap.rvs(iY) = mle(PrtClassMap.rvs(iY), PrtDataSet.getObservationsByClassInd(iY));
end