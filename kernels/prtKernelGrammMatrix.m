function gramm = prtKernelGrammMatrix(DataSetEval,kernelFunctions)
%gramm = prtKernelGrammMatrix(DataSetEval,kernelFunctions)

gramm = nan(DataSetEval.nObservations,length(kernelFunctions));
for i = 1:length(kernelFunctions);
    if isa(DataSetEval,'prtDataSetBase')
        %this is way faster than looping over DataSetEval.getObservations(i)
        gramm(:,i) = kernelFunctions{i}.run(DataSetEval.getObservations()); 
    else
        gramm(:,i) = kernelFunctions{i}.run(DataSetEval);
    end
end