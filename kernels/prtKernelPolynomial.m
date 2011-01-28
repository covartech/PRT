classdef prtKernelPolynomial < prtKernel
    % prtKernelPolynomial  Polynomial kernel object
    %
    %  kernelObj = prtKernelPolynomial; Generates a kernel object implementing a
    %  polynomial kernel.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  Polynomial kernels
    %  implement the following function for 1 x N vectors x1 and x2:
    %
    %   k(x1,x2) = (x*y'+c).^d;
    %
    %  kernelObj = prtKernelPolynomial(param,value,...) with parameter value
    %  strings sets the relevant fields of the prtKernelPolynomial object to have
    %  the corresponding values.  prtKernelPolynomial objects have the
    %  following user-settable properties:
    %
    %   d   - Positive scalar value specifying the order of the polynomial.
    %       (Default value is 2)
    %
    %   c   - Positive scalar indicating the offset of the polynomial.
    %        (Default value is 0)
    %
    %  Polynomial kernels are widely used in the machine
    %  learning literature. For more information on these kernels, please
    %  refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  % Example usage:
    %   ds = prtDataGenBimodal;
    %   k1 = prtKernelPolynomial;
    %   k2 = prtKernelPolynomial('d',3);
    %   
    %   g1 = k1.evaluateGram(ds,ds);
    %   g2 = k2.evaluateGram(ds,ds);
    %
    %   subplot(2,2,1); imagesc(g1); 
    %   subplot(2,2,2); imagesc(g2);
    %
    %
    
    properties (SetAccess = private)
        name = 'Hyperbolic Tangent Kernel';
        nameAbbreviation = 'TANH';
        isSupervised = false;
    end
    
    properties (Hidden)
        internalDataSet
    end
    
    properties
        d = 2;    % polynomial order
        c = 0;    % offset
    end
    properties (SetAccess = 'protected')
        kernelCenter = [];   % The kernel center; set during training
    end
    methods
        function obj = set.d(obj,value)
            assert(isscalar(value) && value > 0,'d parameter must be scalar and > 0, value provided is %s',mat2str(value));
            obj.d = value;
        end
        
        function obj = prtKernelPolynomial(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelHyperbolicTangent:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = Obj.internalDataSet.nObservations;
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelHyperbolicTangent:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelHyperbolicTangent:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
            end
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.internalDataSet = Obj.internalDataSet.retainObservations(keepLogical);
        end
        
    end
    
    methods (Access = protected, Hidden = true)
        function Obj = trainAction(Obj,ds)
            Obj.internalDataSet = ds;
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelPolynomial.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,Obj.d,Obj.c);
                dsOut = ds.setObservations(gram);
            end
        end
        
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,d,c)
            [n1, dim1] = size(x);
            [n2, dim2] = size(y);
            if dim1 ~= dim2
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = (x*y'+c).^d;
        end
    end
end
