function gramm = prtKernelGrammMatrix(DataSetEval,kernelFunctions)
%gramm = prtKernelGrammMatrix(DataSetEval,kernelFunctions)

gramm = nan(DataSetEval.nObservations,length(kernelFunctions));
for i = 1:length(kernelFunctions);
    if isa(DataSetEval,'prtDataSetBase')
        %this is way faster than looping over DataSetEval.getObservations(i)
        gramm(:,i) = kernelFunctions{i}.run(DataSetEval.getObservations); 
    else
        gramm(:,i) = kernelFunctions{i}.run(DataSetEval);
    end
end

%
% 
% %translate to cell
% if isa(kernelFunctions,'function_handle');
%     [gramm,nBasis,kFn] = prtKernelGrammMatrix(xTest,xTrain,{kernelFunctions});
%     return;
% end
% 
% if ~isa(kernelFunctions,'cell')
%     error('grammMatrix.m requires kernelFunctions to be a cell array of function handles');
% end
% 
% [n1, d] = size(xTest);
% [n2, nin] = size(xTrain);
% 
% if d ~= nin
%     error('The dimensionality of xTest (%d) is not equal to the dimensionality of xTrain (%d)',d,nin);
% end
% 
% %evaluate each kernel function, and concatenate the results to the gramm
% %matrix
% nBasis = zeros(1,length(kernelFunctions));
% gramm = [];  %there's no good way to pre-allocate this, unfortunately
% kFn = {};
% 
% for i = 1:length(kernelFunctions)
%     %Basic error checking:
%     if ~isa(kernelFunctions{i},'function_handle')
%         error('Element %d of kernelFunctions is not a function_handle, it is a %s',i,class(kernelFunctions{i}));
%     elseif nargin(kernelFunctions{i}) ~= 2 && nargin(kernelFunctions{i}) ~= 1
%         error('Element %d of kernelFunctions takes %d arguments, it should take 1 or 2',i,nargin(kernelFunctions{i}));
%     else %kernel seems good:
%         if nargin(kernelFunctions{i}) == 2
%             tempGramm = kernelFunctions{i}(xTest,xTrain);
%             gramm = cat(2,gramm,tempGramm);
%             nBasis(i) = size(xTrain,1);
%             if nBasis(i) ~= size(tempGramm,2)
%                 error('nBasis is not equal to number of training points and nargin(kernel) = 2; did you mean to use a unary kernel?');
%             end
%             for j = 1:size(xTrain,1)
%                 kFn{end+1} = prtKernelToUnaryKernel(kernelFunctions{i},xTrain(j,:));
%             end
%         elseif nargin(kernelFunctions{i}) == 1
%             tempGramm = kernelFunctions{i}(xTest);
%             nBasis(i) = size(tempGramm,2);
%             gramm = cat(2,gramm,tempGramm);
%             kFn{end+1} = kernelFunctions{i};
%         end
%     end
% end
% 
