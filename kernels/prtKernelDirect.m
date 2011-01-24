classdef prtKernelDirect < prtKernelFeatureDependent
    % prtKernelDirect  Direct kernel
    %
    %  kernelObj = prtKernelDirect; Generates a kernel object implementing a
    %  direct kernel function.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  Direct kernels
    %  implement the following function for 1 x N vectors x1 and x2:
    %
    %   k(x1,x2) = x2(obj.featureDimension)
    %
    %  Direct kernel functions can be used sparse machine learning contexts
    %  to perform sparse linear feature selection.
    %   
    %  % Example usage:
    %   close all;
    %   ds = prtDataGenUnimodal;
    %   k1 = prtKernelDirect;
    %   
    %   g1 = k1.evaluateGram(ds,ds);
    %
    %   subplot(1,1,1); imagesc(g1);
    %
    
    properties (SetAccess = 'protected')
        fnHandle
        dimension
    end
    
    methods 
        
        function kernelObj = prtKernelDirect(varargin)
            kernelObj = prtUtilAssignStringValuePairs(kernelObj,varargin{:});
        end
        
        function yOut = evalKernel(obj,x)
            yOut = x(:,obj.dimension);
        end
        function obj = trainKernel(obj,theDimension)
            obj.dimension = theDimension;
        end
    end
end