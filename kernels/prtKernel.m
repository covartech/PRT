classdef prtKernel
 % prtKernel   Base class for prtKernel Objects.
 %
 % prtKernel is an abstract class and cannot be instantiated.
 
    properties (Abstract, SetAccess = 'protected')
        fnHandle
    end
    properties (SetAccess = 'protected')
        isInitialized = false;  % Flag indicating whether or not kernel is initialized
    end
    
    methods
        function values = run(obj,y)
            % RUN  Evaluate a prtKernel object.
            %
            %    RESULT = kern.RUN(Y) outputs the result of evaluating the
            %    prtKernel object KERN at the value Y. If Y is 1xM, RESULT is
            %    column vector, evaluating RESULT at each kernel center of the
            %    KERN object. If Y is NxM, RESULT is the Gramm matrix
            %    evaluation, computing the kernel function of each all N
            %    elements of Y, at all M-dimension kernel centers of the KERN
            %    object.
            if ~obj.isInitialized
                error('Kernel object is not initialized; use obj = initializeKernelArray(obj,x) to initialize');
            end
            if isa(y,'double')
                values = obj.fnHandle(y);
            elseif isa(y,'prtDataSetBase')
                values = nan(y.nObservations,1);
                for i = 1:y.nObservations
                    values(i) = obj.fnHandle(y.getObservations(i));
                end
            end
        end
        function h = classifierPlot(obj)
            h = nan;
        end
        function h = classifierText(obj)
            h = nan;
        end
    end
    methods (Abstract)
        objectArray = initializeKernelArray(obj,x)
  
    end
end