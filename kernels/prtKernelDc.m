classdef prtKernelDc < prtKernel
    % prtKernelDc  DC kernel object
    %
    % kernelObj = prtKernelDc create a prtKernelDc object that implements a
    % constant function.  Kernel objects are widely used in several prt
    % classifiers, such as prtClassRvm and prtClassSvm.  DC kernels are
    % important in both RVM and SVM classifiers, and are usually included
    % to account for any DC offset in the target labels. DC kernels
    % implement the following function for 1 x N vectors x1 and x2:
    %
    %  k(x1,x2) = 1;
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDirect,
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


    % Internal help:
    %
    % Note that since prtKernelDc is a prtKernelUnary, it output a single
    % column of the Gram matrix regardless of the dimensionality of the
    % input vectors when using evaluateGram.  This is to ensure that the
    % Gram matrix stays positive definite, and also to save memory and
    % computation time. 
    %
    %
    
    properties (SetAccess = private)
        name = 'DC Kernel';   % DC Kernel
        nameAbbreviation = 'DCKern';   % DCKern
    end
    
    properties (Access = 'protected', Hidden = true)
        isRetained = true;
    end
    
    methods (Access = protected, Hidden = true)
        
        function obj = trainAction(obj,twiddle)
            %do nothing
            obj.isTrained = true;
        end
        
        function yOut = runAction(obj,ds2)
            if obj.isRetained
                yOutData = ones(ds2.nObservations,1);
                yOut = ds2.setObservations(yOutData);
            else
                yOut = prtDataSetClass;
            end
        end
    end
    
    methods
        function obj = prtKernelDc(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            obj.isTrained = true; %we're always trained...
        end
        
    end
    
    methods (Hidden = true)
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelRbf:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = double(Obj.isRetained);
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelRbf:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelRbf:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
            end
            
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            Obj.isRetained = keepLogical;
        end
    end
end
