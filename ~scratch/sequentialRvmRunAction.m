function yOut = sequentialRvmRunAction(Obj,x)

memChunkSize = 1000; % Should this be moved somewhere?
n = size(x,1);

OutputMat = zeros(n,1);
for i = 1:memChunkSize:n;
    cI = i:min(i+memChunkSize,n);
    
    gram = runMultiKernel(Obj.sparseKernels,x(cI,:));
    
    yOut(cI,1) = prtRvUtilNormCdf(gram*Obj.sparseBeta);
end

end



function blockPhi = runMultiKernel(trainedKernelCell,x)
blockPhi = zeros(length(x),length(trainedKernelCell));
for i = 1:length(trainedKernelCell)
    blockPhi(:,i) = trainedKernelCell{i}(x);
end
end