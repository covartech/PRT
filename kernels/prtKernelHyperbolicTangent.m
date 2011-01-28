classdef prtKernelHyperbolicTangent < prtKernel
    % prtKernelHyperbolicTangent  Hyperbolic tangent kernel
    %
    %  kernelObj = prtKernelHyperbolicTangent; Generates a kernel object
    %  implementing a hyperbolic tangent.  Kernel objects are widely used
    %  in several prt classifiers, such as prtClassRvm and prtClassSvm.
    %  Hyperbolic tangent kernels implement the following function for 1 x
    %  N vectors x1 and x2:
    %
    %   k(x1,x2) = tanh(kappa*x1*x2'+c);
    %
    %  kernelObj = prtKernelHyperbolicTangent(param,value,...) with
    %  parameter value strings sets the relevant fields of the
    %  prtKernelHyperbolicTangent object to have the corresponding values.
    %  prtKernelHyperbolicTangent objects have the following user-settable
    %  properties:
    %
    %   kappa   - Positive scalar value specifying the gain on the inner
    %      product between x1 and x2 (default 1)
    %
    %   c       - Scalar value specifying DC offset in hyperbolic tangent
    %      function
    %
    %  For more information on these kernels, please refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  % Example usage:
    %   ds = prtDataGenBimodal;
    %
    %   k1 = prtKernelHyperbolicTangent;
    %   k2 = prtKernelHyperbolicTangent('kappa',2);
    %   
    %   k1 = k1.train(ds); % Train
    %   g1 = k1.run(ds); % Evaluate
    %
    %   k2 = k2.train(ds); % Train
    %   g2 = k2.run(ds); % Evaluate
    %
    %   subplot(2,2,1); imagesc(g1.getObservations);  %Plot the results
    %   subplot(2,2,2); imagesc(g2.getObservations);
    %
    
    properties (SetAccess = private)
        name = 'Hyperbolic Tangent Kernel';
        nameAbbreviation = 'TANH';
        isSupervised = false;
    end
    properties
        kappa = 1;    % polynomial order
        c = 0;    % offset
    end

    properties (Hidden)
        internalDataSet
    end
    
    methods
        function obj = set.kappa(obj,value)
            assert(isscalar(value) && value > 0,'kappa parameter must be scalar and > 0, value provided is %s',mat2str(value));
            obj.kappa = value;
        end
        
        function obj = set.c(obj,value)
            assert(isscalar(value),'c parameter must be scalar, value provided is %s',mat2str(value));
            obj.c = value;
        end
        
        function obj = prtKernelHyperbolicTangent(varargin)
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
                gram = prtKernelHyperbolicTangent.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,Obj.kappa,Obj.c);
                dsOut = ds.setObservations(gram);
            end
        end
        
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,kappa,c)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = tanh(kappa*x*y'+c);
        end
    end
end
