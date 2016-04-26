classdef prtKernelDc < prtKernel
    % prtKernelDc  DC kernel object
    %
    % kernelObj = prtKernelDc create a prtKernelDc object that implements a
    % constant function.  Kernel objects are widely used in several prt
    % classifiers, such as prtClassRvm and prtClassSvm.  DC kernels are
    % important in both RVM and SVM classifiers, and are usually included
    % to account for any DC offset in the target labels. DC kernels
    % implement the following function for 1 x N vectors x1 and x2:
    %
    %  k(x1,x2) = 1;
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDirect,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial, prtKernelRbf,
    %   prtKernelRbfNdimensionScale, 







    % Internal help:
    %
    % Note that since prtKernelDc is a prtKernelUnary, it output a single
    % column of the Gram matrix regardless of the dimensionality of the
    % input vectors when using evaluateGram.  This is to ensure that the
    % Gram matrix stays positive definite, and also to save memory and
    % computation time. 
    %
    %
    
    properties (SetAccess = private)
        name = 'DC Kernel';   % DC Kernel
        nameAbbreviation = 'DCKern';   % DCKern
    end
    
    properties (Access = 'protected', Hidden = true)
        isRetained = true;
    end
    
    methods (Access = protected, Hidden = true)
        
        function obj = trainAction(obj,twiddle)
            %do nothing
            obj.isTrained = true;
        end
        
        function yOut = runAction(obj,ds2)
            if obj.isRetained
                yOutData = ones(ds2.nObservations,1);
                yOut = ds2.setObservations(yOutData);
            else
                yOut = prtDataSetClass;
            end
        end
    end
    
    methods
        function obj = prtKernelDc(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            obj.isTrained = true; %we're always trained...
        end
        
    end
    
    methods (Hidden = true)
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelRbf:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = double(Obj.isRetained);
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelRbf:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelRbf:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
            end
            
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.isRetained = keepLogical;
        end
    end
end
