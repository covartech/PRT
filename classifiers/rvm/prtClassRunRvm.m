function [ClassifierResults,Etc] = prtClassRunRvm(PrtRvm,DS)

Etc = [];

n = DS.nObservations;
if DS.nObservations > 1000
    y = zeros(n,1);
    step = 1000;
    for i = 1:step:n;
        cI = i:min(i+step,n);
        gramm = prtKernelGrammMatrix(DS.data(cI,:),PrtRvm.PrtDataSet.data,PrtRvm.PrtOptions.kernel);
        y(cI) = normcdf(gramm*PrtRvm.Beta);
    end
else
    gramm = prtKernelGrammMatrix(DS.data,PrtRvm.PrtDataSet.data,PrtRvm.PrtOptions.kernel);
    y = normcdf(gramm*PrtRvm.Beta);
end

ClassifierResults = prtDataSetUnLabeled(y);