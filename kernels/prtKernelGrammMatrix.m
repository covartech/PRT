function [gramm,nBasis] = prtKernelGrammMatrix(x1,x2,kernelFunctions)
%[gramm,nBasis] = prtKernelGrammMatrix(x1,x2,kernelFunctions);
%
%   

%translate to cell
if isa(kernelFunctions,'function_handle');
    [gramm,nBasis] = prtKernelGrammMatrix(x1,x2,{kernelFunctions});
    return;
end

if ~isa(kernelFunctions,'cell')
    error('grammMatrix.m requires kernelFunctions to be a cell array of function handles');
end

[n1, d] = size(x1);
[n2, nin] = size(x2);

if d ~= nin
    error('The dimensionality of x1 (%d) is not equal to the dimensionality of x2 (%d)',d,nin);
end

%evaluate each kernel function, and concatenate the results to the gramm
%matrix
nBasis = zeros(1,length(kernelFunctions));
gramm = [];  %there's no good way to pre-allocate this, unfortunately

for i = 1:length(kernelFunctions)
    %Basic error checking:
    if ~isa(kernelFunctions{i},'function_handle')
        error('Element %d of kernelFunctions is not a function_handle, it is a %s',i,class(kernelFunctions{i}));
    elseif nargin(kernelFunctions{i}) ~= 2
        error('Element %d of kernelFunctions takes %d arguments, it should take 2',i,nargin(kernelFunctions{i}));
    else %kernel seems good:
        tempGramm = kernelFunctions{i}(x1,x2);
        gramm = cat(2,gramm,tempGramm);
        nBasis(i) = size(tempGramm,2);
    end
end

