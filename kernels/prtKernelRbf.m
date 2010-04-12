classdef prtKernelRbf < prtKernelBinary
    
    properties
        c = 1;
    end
    properties (SetAccess = 'protected')
        fnHandle
        kernelCenter = nan;
    end
    methods 
        function obj = initializeBinaryKernel(obj,x)
            obj.kernelCenter = x;
            obj.fnHandle = @(y) prtKernelRbf.rbfEvalKernel(obj.kernelCenter,y,obj.c);
            obj.isInitialized = true;
        end
        function h = classifierPlot(obj)
            switch(size(obj.kernelCenter,2))
                case 1
                    h = plot(obj.kernelCenter,0,'ko');
                case 2
                    h = plot(obj.kernelCenter(1),obj.kernelCenter(2),'ko');
                case 3
                    h = plot3(obj.kernelCenter(1),obj.kernelCenter(2),'ko');
                otherwise
                    h = nan;
            end
        end
        
        %Should really use latex, or have toLatex
        function string = toString(obj)
            string = sprintf('  f(x) = exp(-(x - %s)./(2*%.2f^2))',mat2str(obj.kernelCenter,2),obj.c);
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
    
    methods (Static)
        function gramm = rbfEvalKernel(x,y,c)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            dist2 = repmat(sum((x.^2)', 1), [n2 1])' + ...
                repmat(sum((y.^2)',1), [n1 1]) - ...
                2*x*(y');
            
            %gramm = exp(-dist2/(c.^2));
            gramm = exp(-bsxfun(@rdivide,dist2,2*c.^2));
        end
    end
end