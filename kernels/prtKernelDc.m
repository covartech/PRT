classdef prtKernelDc < prtKernelUnary
    % prtKernelDc  DC kernel object
    %
    % kernelObj = prtKernelDc; Generates a kernel object implementing a
    % constant function.  Kernel objects are widely used in several
    % prt classifiers, such as prtClassRvm and prtClassSvm.  DC kernels
    % implement the following function for 1 x N vectors x1 and x2:
    %
    %  k(x1,x2) = 1;
    %
    % Note that since prtKernelDc is a prtKernelUnary, it output a single
    % column of the Gram matrix regardless of the dimensionality of the
    % input vectors when using evaluateGram.  This is to ensure that the
    % Gram matrix stays positive definite, and also to save memory and
    % computation time.  DC kernels are important in both RVM and SVM
    % classifiers, and are usually included to account for any DC offset in
    % the target labels.
    %
    %
    methods 
        function obj = prtKernelDc(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = trainKernel(obj,x)
            %do nothing
        end
        function yOut = evalKernel(obj,ds2)
            yOut = ones(size(ds2,1),1);
        end
        
    end
end