classdef prtKernel < prtAction
    % prtKernel  Base class for prtKernel objects.
    %
    %   prtKernel is the base class for all prtKernel objects. It is an
    %   abstract class and should not be instantiated. All prtKernel
    %   objects implement the following methods:
    %
    %   X = evaluateGram(OBJ,DS1,DS2)Evaluate the kernel object OBJ trained
    %   at all points in DS1 and evaluated at all points in DS2.  This will
    %   ouput a gram matrix of size DS2.nObservations x
    %   getExpectedNumKernels(OBJ,DS1). This is the main interface function
    %   for most kernel operations.
    %
    %   TRAINEDKERNELCELL = toTrainedKernelArray(OBJ,DSTRAIN,DATAPOINTS)
    %   Output a cell array of M trained kernel objects trained using
    %   the data in prtDataSet DSTRAIN at the observations specified in
    %   DATAPOINTS. DATAPOINTS must be a logical array indicating which
    %   elements of DSTRAIN should be used in training. The default
    %   value is all datapoints.  The trained kernel cell can be used
    %   to maintain only a sparse list of kernels in sparse learning
    %   machines such as used by prtClassRVM, prtClassSVM.
    %
    %   yOut = run(OBJ,DSTEST) Run a trained kernel object (one element of
    %   toTrainedKernelArray) on the data in dsTest.
    %
    %   nDims = getExpectedNumKernels(OBJ,DSTRAIN) Output an integer
    %   containing of the expected number of trained kernels that would be
    %   created using toTrainedKernelArray on all the observations in the
    %   data set DSTRAIN.  For binary kernesls such as prtKernelRbf,
    %   prtKernelPolynomial, this is DSTRSAIN.nObservations, for unary
    %   kernels such as prtKernelDc kernels. this is 1. Other kernel
    %   objects might use other specifications.
    %
    %  See also: prtKernelRbf, prtKernelBinary, prtKernelDc, prtKernelDirect,
    %   prtKernelFeatureDependent, prtKernelHyperbolicTangent,
    %   prtKernelPolynomial,  prtKernelRbfNdimensionScale, prtKernelUnary
    
    
    methods
        function obj = prtKernel()
            obj.isCrossValidateValid = false;
            obj.verboseStorage = false;
        end
    end
    
    methods (Abstract)
        nDimensions = nDimensions(Obj)
        Obj = retainKernelDimensions(Obj,keepLogical)
    end
    
    
    methods (Hidden)  %internal, can make things faster in some classifiers
        function gramMatrix = run_OutputDoubleArray(Obj,DataSet)
            dsOut = Obj.run(DataSet);
            gramMatrix = dsOut.getObservations;
        end
    end
    
    methods
        function Obj3 = and(Obj1,Obj2)
            if isa(Obj1,'prtKernelSet')
                kernelCell1 = Obj1.getKernelCell;
            elseif isa(Obj1,'prtKernel')
                kernelCell1 = {Obj1};
            else
                error('prt:prtKernel','Invalid input to prtKernel\and, both arguments must be of type prtKernel');
            end
            
            if isa(Obj2,'prtKernelSet')
                kernelCell2 = Obj2.getKernelCell;
            elseif isa(Obj2,'prtKernel')
                kernelCell2 = {Obj2};
            else
                error('prt:prtKernel','Invalid input to prtKernel\and, both arguments must be of type prtKernel');
            end
            Obj3 = prtKernelSet(kernelCell1{:},kernelCell2{:});
        end
    end
    
    methods
        function h = plot(Obj)
            %   do nothing by default; other kernels can overload as they want
            holdState = get(gca,'nextPlot');
            h = plot(nan,nan);
            set(gca,'nextPlot',holdState);
        end
        function txt = toString(obj)
            txt = 'prtKernel';
        end
    end
end