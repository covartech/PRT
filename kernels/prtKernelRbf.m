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
    %  KERNOBJ = prtKernelRbf(PROPERTY1, VALUE1, ...) constructs a
    %  prtKernelRbfNdimensionScale object KERNOBJ with properties as specified by
    %  PROPERTY/VALUE pairs. prtKernelRbf objects have the following
    %  user-settable properties:
    %
    %  KERNOBJ = prtKernelRbf(param,value,...) with parameter value
    %  strings sets the relevant fields of the prtKernelRbf object to have
    %  the corresponding values.  prtKernelRbf objects have the following
    %  user-settable properties:
    %
    %   sigma   - Positive scalar value specifying the width of the
    %             Gaussian kernel in the RBF function.  (Default value is 1)
    %
    %  Radial basis function kernels are widely used in the machine
    %  learning literature. For more information on these kernels, please
    %  refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %   prtKernelRbf objects inherit the TRAIN and RUN methods from prtKernel.
    %
    %   % Example
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
    %   subplot(2,1,1); imagesc(g1.getObservations);  %Plot the results
    %   subplot(2,1,2); imagesc(g2.getObservations);
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc, prtKernelDirect,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial,
    %   prtKernelRbfNdimensionScale, 







    properties (SetAccess = private)
        name = 'RBF Kernel'; % RBF Kernel
        nameAbbreviation = 'RBF'; % RBF
    end
    
    properties
        sigma = 1; % The inverse kernel width
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
            if ~prtUtilIsPositiveScalar(value)
                assert(isnumeric(value) && all(value>0) && isvector(value),'sigma must be a positive numeric vector')
                if isempty(Obj.internalDataSet) || Obj.internalDataSet.nObservations==0
                    error('prtKernelRbf:set','Value of sigma must be a positive scalar');
                else
                    assert(Obj.internalDataSet.nObservations==numel(value),'When setting sigma to be an array of values the internalDataSet must be set and the number of observations and the length of sigma must match');
                end
            end
            Obj.sigma = value(:);
        end
    end
    
    methods(Hidden = true)
        function varargout = plot(obj)
            x = obj.internalDataSet.getObservations;
            
            if size(x,2) <= 3
                if size(x,2) == 1 && obj.internalDataSet.isLabeled
                    xy = cat(2,x,obj.internalDataSet.getTargets);
                    h = prtPlotUtilScatter(xy, {}, obj.plotOptions.symbol, obj.plotOptions.markerFaceColor, obj.plotOptions.color, obj.plotOptions.symbolLineWidth, obj.plotOptions.symbolSize);
                else
                    h = prtPlotUtilScatter(x, {}, obj.plotOptions.symbol, obj.plotOptions.markerFaceColor, obj.plotOptions.color, obj.plotOptions.symbolLineWidth, obj.plotOptions.symbolSize);
                end
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
                gram = exp(-bsxfun(@rdivide,dist2,(sigma.^2)'));
            end
        end
    end
end
