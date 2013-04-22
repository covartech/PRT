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
    %   kernel = and(kernel1,kernel2) Combine two kernels into a
    %   prtKernelSet (also a prtKernel).  This is used to join multiple
    %   kernels together.  Unlike the plus operation for combining
    %   prtActions, the AND operation trains and runs each kernel
    %   individually on the provided data.
    %
    %   Note, cross validation is not a valid operation on prtKernel
    %   objects, and therefore the CROSSVALIDATE and KFOLDS operations are
    %   not implemented.
    %
    %   % Example syntax of the AND method:
    %
    %   kernels = prtKernelDc & prtKernelRbf; % kernels is prtKernelSet
    %
    %  See also: prtKernelRbf, prtKernelSet, prtKernelDc, prtKernelDirect,
    %  prtKernelHyperbolicTangent, prtKernelPolynomial,
    %  prtKernelRbfNdimensionScale,

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
    %
    %   nDims = kernel.nDimensions Output the number of columns that should
    %   be expected in the output of kernel.run.  For many kernels (RBF,
    %   Polynomial, HyperbolicTangent), nDimensions is the number of
    %   observations in the training dataSet.  For other kernels (DC),
    %   nDimensions is a constant (1).  For other kernels (e.g. Direct),
    %   the number of columns is the number of features in the training
    %   data set.
    
    properties (Hidden = true)
        plotOptions = prtKernel.initializePlotOptions();        
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = false; % False
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
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            obj.classTrain = 'prtDataSetStandard';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = false;
        
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
                error('prtKernel:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = Obj.internalDataSet.nObservations;
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernel:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernel:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
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
            % Combine 2 prtKernels into a prtKernelSet
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
            % Return a descriptive string
            txt = 'prtKernel';
        end
    end
    
    methods (Static, Hidden = true)
        function plotOptions = initializePlotOptions()            
            if ~isdeployed
                plotOptions = prtOptionsGet('prtOptionsKernelPlot');
            else
                plotOptions = prtOptions.prtOptionsKernelPlot;
            end
        end
    end        
end
