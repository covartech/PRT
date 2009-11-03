function [ClassifierResults,Etc] = prtRegRunRvmJeffreys(PrtRvm,DS)

Etc = [];

n = DS.nObservations;
if DS.nObservations > 1000
    y = zeros(n,1);
    step = 1000;
    for i = 1:step:n;
        cI = i:min(i+step,n);
        gramm = prtKernelGrammMatrix(DS.getObservations(cI,:),PrtRvm.PrtDataSet.getObservations,PrtRvm.PrtOptions.kernel);
        y(cI) = gramm*PrtRvm.beta;
    end
else
    gramm = prtKernelGrammMatrix(DS.getObservations,PrtRvm.PrtDataSet.getObservations,PrtRvm.PrtOptions.kernel);
    y = gramm*PrtRvm.beta;
end

ClassifierResults = prtDataSetUnLabeled(y);