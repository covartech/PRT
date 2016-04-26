classdef prtKernelDirect < prtKernel
    % prtKernelDirect  Direct kernel
    %
    %  kernelObj = prtKernelDirect Generates a prtKernelDirect object implementing a
    %  direct kernel function.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  Direct kernels
    %  implement the following function for 1 x N vectors x1 and x2:
    %
    %   k(x1,x2) = x2;
    %
    %  Direct kernel functions can be used sparse machine learning contexts
    %  to perform sparse linear feature selection.
    %   
    %  prtKernelDirect objects inherit the TRAIN, RUN, and AND
    %  methods from prtKernel.
    %
    %  % Example:
    %   ds = prtDataGenUnimodal;   % Load a data set
    %   k1 = prtKernelDirect;      % Create a prtKernelDirect object
    %   
    %   k1 = k1.train(ds);         % Train
    %   g1 = k1.run(ds);           % Run
    %
    %   % Plot the results
    %   imagesc(g1.getObservations);
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial, prtKernelRbf,
    %   prtKernelRbfNdimensionScale, 







    properties (SetAccess = private)
        name = 'Direct Kernel'; % Direct Kernel
        nameAbbreviation = 'DirectKernel';  % DirectKernel
     end
    
    properties (SetAccess = 'protected', Hidden = true)
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
        
    end
    
    methods (Hidden = true)
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelDirect:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = length(find(Obj.retainDimensions));
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelDirect:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelDirect:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
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
