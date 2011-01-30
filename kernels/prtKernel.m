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
    
    properties (Hidden = true)
        PlotOptions = prtKernel.initializePlotOptions();        
    end
    
    properties (Access = protected, Hidden = true)
        internalDataSet
    end
        
    methods (Hidden = true)
        function kfolds(varargin)
            error('K-folds not allowed for Kernel objects');
        end
        function crossValidate(varargin)
            error('crossValidate not allowed for Kernel objects');
        end
    end
    
    methods
        function obj = prtKernel()
            obj.isCrossValidateValid = false;
            obj.verboseStorage = false;
        end
    end
    
    methods (Hidden = true)
        
        %Default behaviour for kernels that make one kernel function for
        %every training input data observation; for kernels that do not do
        %this (e.g. DC kernel, or Direct), these functions have to be
        %overloaded to do the right thing:
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelHyperbolicTangent:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = Obj.internalDataSet.nObservations;
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelHyperbolicTangent:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelHyperbolicTangent:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
            end
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.internalDataSet = Obj.internalDataSet.retainObservations(keepLogical);
        end
    end
    
    methods (Hidden)  %internal, can make things faster in some classifiers
        function gramMatrix = run_OutputDoubleArray(Obj,DataSet)
            dsOut = Obj.run(DataSet);
            gramMatrix = dsOut.getObservations;
        end
    end
    
    methods
        function Obj3 = and(Obj1,Obj2)
            
            if ~isa(Obj1,'prtKernel') || ~isa(Obj2,'prtKernel')
                error('prtKernel:And','Invalid input to prtKernel\\and, both arguments must be of type prtKernel');
            end
            
            if isa(Obj1,'prtKernelSet')
                kernelCell1 = Obj1.getKernelCell;
            else
                kernelCell1 = {Obj1};
            end
            
            if isa(Obj2,'prtKernelSet')
                kernelCell2 = Obj2.getKernelCell;
            else
                kernelCell2 = {Obj2};
            end
            Obj3 = prtKernelSet(kernelCell1{:},kernelCell2{:});
        end
    end
    
    methods (Hidden = true)
        function varargout = plot(Obj) %#ok<MANU>
            %   do nothing by default; other kernels can overload as they want
            holdState = get(gca,'nextPlot');
            h = plot(nan,nan);
            set(gca,'nextPlot',holdState);
            varargout = {};
           
            if nargout
                varargout = {h};
            end
            
        end
        function txt = toString(obj) %#ok<MANU>
            txt = 'prtKernel';
        end
    end
    
    methods (Static, Hidden = true)
        function PlotOptions = initializePlotOptions()
            PlotOptions = prtOptionsGet('prtOptionsKernelPlot');
        end
    end        
end