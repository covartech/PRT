function [ClassifierResults,Etc] = prtClassRunRvm(PrtRvm,DS)

Etc = [];

n = DS.nObservations;
if DS.nObservations > 1000
    y = zeros(n,1);
    step = 1000;
    for i = 1:step:n;
        cI = i:min(i+step,n);
        if ~isfield(PrtRvm,'sparseKernels')
            gramm = prtKernelGrammMatrix(DS.getObservations(cI,:),PrtRvm.PrtDataSet.getObservations,PrtRvm.PrtOptions.kernel);
            y(cI) = normcdf(gramm*PrtRvm.Beta);
        else
            gramm = prtKernelGrammMatrixUnary(DS.getObservations(cI,:),PrtRvm.sparseKernels);
            y(cI) = normcdf(gramm*PrtRvm.sparseBeta);
        end
        
    end
else
    if ~isfield(PrtRvm,'sparseKernels')
        gramm = prtKernelGrammMatrix(DS.getObservations,PrtRvm.PrtDataSet.getObservations,PrtRvm.sparseKernels);
        y = normcdf(gramm*PrtRvm.Beta);
    else
        gramm = prtKernelGrammMatrixUnary(DS.getObservations,PrtRvm.sparseKernels);
        y = normcdf(gramm*PrtRvm.sparseBeta);
    end
end

ClassifierResults = prtDataSetUnLabeled(y);