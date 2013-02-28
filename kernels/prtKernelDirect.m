classdef prtKernelDirect < prtKernel
    % prtKernelDirect  Direct kernel
    %
    %  kernelObj = prtKernelDirect Generates a prtKernelDirect object implementing a
    %  direct kernel function.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  Direct kernels
    %  implement the following function for 1 x N vectors x1 and x2:
    %
    %   k(x1,x2) = x2;
    %
    %  Direct kernel functions can be used sparse machine learning contexts
    %  to perform sparse linear feature selection.
    %   
    %  prtKernelDirect objects inherit the TRAIN, RUN, and AND
    %  methods from prtKernel.
    %
    %  % Example:
    %   ds = prtDataGenUnimodal;   % Load a data set
    %   k1 = prtKernelDirect;      % Create a prtKernelDirect object
    %   
    %   k1 = k1.train(ds);         % Train
    %   g1 = k1.run(ds);           % Run
    %
    %   % Plot the results
    %   imagesc(g1.getObservations);
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial, prtKernelRbf,
    %   prtKernelRbfNdimensionScale, 

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


    properties (SetAccess = private)
        name = 'Direct Kernel'; % Direct Kernel
        nameAbbreviation = 'DirectKernel';  % DirectKernel
     end
    
    properties (SetAccess = 'protected', Hidden = true)
        retainDimensions
    end
    
    methods (Access = protected, Hidden = true)
        
        function obj = trainAction(obj,ds)
            obj.retainDimensions = true(1,ds.nFeatures);
        end
        
        function yOut = runAction(obj,ds)
            yOut = ds.retainFeatures(obj.retainDimensions);
        end
    end
    methods
        function kernelObj = prtKernelDirect(varargin)
            kernelObj = prtUtilAssignStringValuePairs(kernelObj,varargin{:});
        end
        
    end
    
    methods (Hidden = true)
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelDirect:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = length(find(Obj.retainDimensions));
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelDirect:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelDirect:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
            end
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.retainDimensions = keepLogical;
        end
    end
end
