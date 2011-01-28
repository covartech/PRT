classdef prtKernelDirect < prtKernel
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
    
    properties (SetAccess = private)
        name = 'Direct Kernel';
        nameAbbreviation = 'DirectKernel';
        isSupervised = false;
     end
    
    properties (SetAccess = 'protected')
        retainDimensions
    end
    
    methods (Access = protected, Hidden = true)
        
        function obj = trainAction(obj,ds)
            obj.retainDimensions = true(1,ds.nFeatures);
        end
        
        function yOut = runAction(obj,ds)
            yOut = ds.retainFeatures(obj.retainDimensions);
        end
    end
    methods
        function kernelObj = prtKernelDirect(varargin)
            kernelObj = prtUtilAssignStringValuePairs(kernelObj,varargin{:});
        end
        
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelDirect:getNumDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = length(find(Obj.retainDimensions));
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelDirect:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.getNumDimensions
                error('prtKernelDirect:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.getNumDimensions (%d)',length(keepLogical),Obj.getNumDimensions);
            end
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.retainDimensions = keepLogical;
        end
    end
end