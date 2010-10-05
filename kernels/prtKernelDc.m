classdef prtKernelDc < prtKernel
    
    methods 
        function obj = prtKernelDc(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function trainedKernelArray = toTrainedKernelArray(obj,dsTrain,logical)
            trainedKernelArray = obj.train(nan);
        end
        
        function obj = train(obj,x)
            %do nothing
        end
        function yOut = run(obj,ds2)
            yOut = ones(ds2.nObservations,1);
        end
        
        function nDims = getExpectedNumKernels(obj,ds)
            nDims = 1;
        end
        
        function gramm = evaluateGramm(obj,ds1,ds2)
            gramm = ones(ds2.nObservations,1);
        end
        
        %Should really use latex, or have toLatex
        function string = toString(obj)
            % TOSTRING  String description of kernel function
            %
            % STR = KERN.toString returns a string description of the
            % kernel function realized by the prtKernel objet KERN.
            
            string = sprintf('ones');
        end
    end
end