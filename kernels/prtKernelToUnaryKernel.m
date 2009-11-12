function unaryKernel = prtKernelToUnaryKernel(kernel,xTrain)
%unaryKernel = prtKernelToUnaryKernel(kernel,xTrain)

unaryKernel = @(xTest)kernel(xTest,xTrain);