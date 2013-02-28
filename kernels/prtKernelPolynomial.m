classdef prtKernelPolynomial < prtKernel
    % prtKernelPolynomial  Polynomial kernel object
    %
    %  kernelObj = prtKernelPolynomial; Generates a kernel object implementing a
    %  polynomial kernel.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  Polynomial kernels
    %  implement the following function for 1 x N vectors x1 and x2:
    %
    %   k(x,y) = (x*y'+c).^d;
    %
    %  KERNOBJ = prtKernelPolynomial(PROPERTY1, VALUE1, ...) constructs a
    %  prtKernelPolynomial object KERNOBJ with properties as specified by
    %  PROPERTY/VALUE pairs. prtKernelPolynomial objects have the following
    %  user-settable properties:
    %
    %   d   - Positive scalar value specifying the order of the polynomial.
    %         (Default value is 2)
    %
    %   c   - Positive scalar indicating the offset of the polynomial.
    %         (Default value is 0)
    %
    %   prtKernelPolynomial objects inherit the TRAIN, RUN, and AND
    %   methods from prtKernel.
    %
    %  Polynomial kernels are widely used in the machine
    %  learning literature. For more information on these kernels, please
    %  refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  % Example:
    %   ds = prtDataGenBimodal;         % Load a data set
    %   k1 = prtKernelPolynomial;       % Create 2 kernels to compare
    %   k2 = prtKernelPolynomial('d',3);
    %   
    %   k1 = k1.train(ds); % Train
    %   g1 = k1.run(ds);   % Evaluate
    %
    %   k2 = k2.train(ds); % Train
    %   g2 = k2.run(ds);   % Evaluate
    %
    %   subplot(2,1,1); imagesc(g1.getObservations);  %Plot the results
    %   subplot(2,1,2); imagesc(g2.getObservations);
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc, prtKernelDirect,
    %   prtKernelHyperbolicTangent, prtKernelRbf,
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
        name = 'Polynomial Kernel'; % Polynomial Kernel
        nameAbbreviation = 'Poly';  % Poly
    end
    
    properties
        d = 2;    % Polynomial order
        c = 0;    % Offset
    end
    properties (SetAccess = 'protected', Hidden = true)
        kernelCenter = [];   % The kernel center; set during training
    end
    methods
        function obj = set.d(obj,value)
            assert(isscalar(value) && value > 0,'d parameter must be scalar and > 0, value provided is %s',mat2str(value));
            obj.d = value;
        end
        
        function obj = prtKernelPolynomial(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        function Obj = trainAction(Obj,ds)
            Obj.internalDataSet = ds;
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelPolynomial.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,Obj.d,Obj.c);
                dsOut = ds.setObservations(gram);
            end
        end
        
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,d,c)
            [n1, dim1] = size(x); %#ok<ASGLU>
            [n2, dim2] = size(y); %#ok<ASGLU>
            if dim1 ~= dim2
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = (x*y'+c).^d;
        end
    end
end
