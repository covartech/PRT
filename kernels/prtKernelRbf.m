classdef prtKernelRbf < prtKernelBinary
    % prtKernelRbf  Radial basis function kernel
    %
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  See also  prtKernelRbfNdimensionScale, prtKernelPolynomial, prtKernelVoigt, prtKernelDc,
    %  prtKernelLaplacian,prtKernelQuadExpCovariance
    
    properties
        sigma = 1;    % Inverse kernel width
    end
    properties (SetAccess = 'protected')
        kernelCenter = [];   % The kernel center
    end
    methods
        function obj = set.sigma(obj,value)
            assert(isscalar(value) && value > 0,'sigma parameter must be scalar and > 0, value provided is %s',mat2str(value));
            obj.sigma = value;
        end
        
        function obj = prtKernelRbf(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = trainKernel(obj,x)
            obj.kernelCenter = x;
        end
        
        %Should really use latex, or have toLatex
        function string = toString(obj)
            % TOSTRING  String description of kernel function
            %
            % STR = KERN.toString returns a string description of the
            % kernel function realized by the prtKernel objet KERN.
            string = sprintf('  f(x) = exp(-(x - %s)./(%.2f^2))',mat2str(obj.kernelCenter,2),obj.sigma);
        end
        
        function yOut = evalKernel(obj,data)
            yOut = prtKernelRbf.rbfEvalKernel(obj.kernelCenter,data,obj.sigma);
        end
        
    end
    
    methods (Static, Hidden = true)
        function gramm = rbfEvalKernel(x,y,sigma)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');
            
            if numel(sigma) == 1
                gramm = exp(-dist2/(sigma.^2));
            else
                gramm = exp(-bsxfun(@rdivide,dist2,sigma.^2));
            end
        end
    end
    
    
    methods(Hidden = true)
        function h = classifierPlot(obj)
            switch(size(obj.kernelCenter,2))
                case 1
                    h = plot(obj.kernelCenter,0,'ko','MarkerSize',8,'LineWidth',2);
                case 2
                    h = plot(obj.kernelCenter(1),obj.kernelCenter(2),'ko','MarkerSize',8,'LineWidth',2);
                case 3
                    h = plot3(obj.kernelCenter(1),obj.kernelCenter(2), obj.kernelCenter(3),'ko','MarkerSize',8,'LineWidth',2);
                otherwise
                    h = nan;
            end
        end
        %Should really use latex
        function h = classifierText(obj)
            loc = zeros(1,3);
            for i = 1:length(obj.kernelCenter)
                loc(i) = obj.kernelCenter(i);
            end
            h = text(loc(1),loc(2),loc(3),obj.toString);
        end
    end
end