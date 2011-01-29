classdef prtKernelRbf < prtKernel
    % prtKernelRbf  Radial basis function kernel
    %
    %  KERNOBJ = prtKernelRbf Generates a kernel object implementing a
    %  radial basis function.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  RBF kernels
    %  implement the following function for 1 x N vectors x1 and x2:
    %
    %   k(x1,x2) = exp(-sum((x1-x2).^2)./sigma.^2);
    %
    %  KERNOBJ = prtKernelRbf(param,value,...) with parameter value
    %  strings sets the relevant fields of the prtKernelRbf object to have
    %  the corresponding values.  prtKernelRbf objects have the following
    %  user-settable properties:
    %
    %   sigma   - Positive scalar value specifying the width of the
    %       Gaussian kernel in the RBF function.  (Default value is 1)
    %
    %  Radial basis function kernels are widely used in the machine
    %  learning literature. For more information on these kernels, please
    %  refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  % Example
    %   ds = prtDataGenBimodal;       % Generate a dataset
    %   k1 = prtKernelRbf;            % Create a prtKernel object with 
    %                                 % default value of sigma 
    %   k2 = prtKernelRbf('sigma',2); % Create a prtKernel object with
    %                                 % specified value of sigma
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
    %   See also: prtKernel, prtKernelBinary, prtKernelDc, prtKernelDirect,
    %   prtKernelFeatureDependent, prtKernelHyperbolicTangent,
    %   prtKernelPolynomial, prtKernelRbfNdimensionScale, prtKernelUnary
    
    properties (SetAccess = private)
        name = 'RBF Kernel';
        nameAbbreviation = 'RBF';
        isSupervised = false;
    end
    properties
        sigma = 1;
    end 
    
    properties (Access = protected, Hidden = true)
        internalDataSet
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
                gram = prtKernelRbf.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,Obj.sigma);
                dsOut = ds.setObservations(gram);
            end
        end
    end
    
    methods
        function Obj = prtKernelRbf(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.sigma(Obj,value)
            if ~prtUtilIsPostiveScalar(value)
                error('prtKernelRbf:set','Value of sigma must be a positive scalar');
            end
            Obj.sigma = value;
        end
        
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelRbf:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = Obj.internalDataSet.nObservations;
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
            
            Obj.internalDataSet = Obj.internalDataSet.retainObservations(keepLogical);
        end
    end
    
    
    methods(Hidden = true)
        function varargout = plot(obj)
            x = obj.internalDataSet.getObservations;
            
            if size(x,2) <= 3
                h = prtPlotUtilScatter(x, {}, obj.PlotOptions.symbol, obj.PlotOptions.markerFaceColor, obj.PlotOptions.color, obj.PlotOptions.symbolLineWidth, obj.PlotOptions.symbolSize);
            else
                h = nan;
            end
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,sigma)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            %dist2 = prtDistanceLNorm(x,y,2); 
            dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');
            
            if numel(sigma) == 1
                gram = exp(-dist2/(sigma.^2));
            else
                gram = exp(-bsxfun(@rdivide,dist2,sigma.^2));
            end
        end
    end
end