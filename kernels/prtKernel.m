classdef prtKernel < prtAction
    % prtKernel  Base class for prtKernel objects.
    %
    %   prtKernel is the base class for all prtKernel objects. It is an
    %   abstract class and should not be instantiated. All prtKernel
    %   objects implement the following methods:
    %
    %   kernel = kernel.train(dataSet) Train the kernel using the specified
    %   dataSet.  This builds a trained kernel object that can be run.
    %
    %   yOut = kernel.run(dataSet) Run a trained kernel object on the data
    %   in dataSet and output the resulting gram matrix in
    %   yOut.getObservations.
    %
    %   nDims = kernel.nDimensions Output the number of columns that should
    %   be expected in the output of kernel.run.  For many kernels (RBF,
    %   Polynomial, HyperbolicTangent), nDimensions is the number of
    %   observations in the training dataSet.  For other kernels (DC),
    %   nDimensions is a constant (1).  For other kernels (e.g. Direct),
    %   the number of columns is the number of features in the training
    %   data set.
    %
    %   kernel = and(kernel1,kernel2) Combine two kernels into a
    %   prtKernelSet (also a prtKernel).  This is used to join multiple
    %   kernels together.  Unlike the plus operation for combining
    %   prtActions, the AND operation trains and runs each kernel
    %   individually on the provided data.
    %
    %   Usually called like: 
    %       kernels = prtKernelDc & prtKernelRbf;
    %
    %  See also: prtKernelRbf, prtKernelBinary, prtKernelDc, prtKernelDirect,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial,  prtKernelRbfNdimensionScale,
    
    % Internal Help:
    %
    % gramMatrix = kernel.run_OutputDoubleArray(dataSet) same as run, but
    % don't output the dataSet, just output dataSet.getObservations.  This
    % saves a lot of time and memory in RVMs
    %
    % h = kernel.plot; Used inside classifiers to display kernels on top of
    % regression and classification plots.
    %
    % h = kernel.toString; Currently unused
    
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