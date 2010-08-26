classdef prtKernelRbf < prtKernelBinary
    % prtKernelRbf  Radial basis function kernel
    %
    %   KERN = prtKernelRbf creates a radial basis function kernel object.
    %
    %   KERN = prtKernelRbf(PROPERTY1, VALUE1, ...) constructs a prtKernelRbf
    %   object KERN with properties as specified by PROPERTY/VALUE pairs.
    %
    %   When the KERN.run(X) is called on a prtKernalBinary object, the kernel
    %   function evaluated is exp(-||x-kernelCenter||/c^2)
    %
    %   A prtKernelRbf object inherits all properties from the abstract class
    %   prtKernel. In addition is has the following property:
    %
    %   c   - Inverse kernel width
    %
    %   A prtKernelRbf inherits the intializeBinaryKernel from the
    %   prtKernelBinary class. It also inherits the run, toString, and
    %   initializeKernelArray functions from the prtKernelBinary class.
    %
    %   Example:
    %   kern = prtKernelRbf;             % Create a prtKernRbf object;
    %   kern.c = 2;                      % Set the c parameter
    %   kern = kern.initializeRbf(2);    % Set the center of the kernel to 2.
    %   result = kern.run(4);            % Run the kernel with input 4
    %   kern.toString;                   % Display a string showing the
    %                                    % equation that the run function
    %                                    % evaluates.
    %
    %  See also  prtKernelRbfNdimensionScale, prtKernelPolynomial, prtKernelVoigt, prtKernelDc,
    %  prtKernelLaplacian,prtKernelQuadExpCovariance
    
    properties
        c = 1;    % Inverse kernel width
    end
    properties (SetAccess = 'protected')
        fnHandle    % Function handle to the kernel
        kernelCenter = nan;   % The kernel center
    end
    methods
        function obj = prtKernelRbf(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function obj = initializeBinaryKernel(obj,x)
            % INITIALIZEBINARYKERNEL  Initialize the prtBinaryKernel Object
            %
            %    KERN = KERN.initializeBinaryKernel(CENTER) initializes the
            %    kernel center of the KERN object to CENTER. CENTER is a
            %    NxM
            %    matrix, where N is the number of kernel functions, and M is the
            %    dimensionality.
            obj.kernelCenter = x;
            obj.fnHandle = @(y) prtKernelRbf.rbfEvalKernel(obj.kernelCenter,y,obj.c);
            obj.isInitialized = true;
        end
        
        
        
        %Should really use latex, or have toLatex
        function string = toString(obj)
            % TOSTRING  String description of kernel function
            %
            % STR = KERN.toString returns a string description of the
            % kernel function realized by the prtKernel objet KERN.
            
            string = sprintf('  f(x) = exp(-(x - %s)./(%.2f^2))',mat2str(obj.kernelCenter,2),obj.c);
        end
        
        
    end
    
    methods (Static)
        function gramm = rbfEvalKernel(x,y,c)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');
            
            if numel(c) == 1
                gramm = exp(-dist2/(c.^2));
            else
                gramm = exp(-bsxfun(@rdivide,dist2,c.^2));
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