classdef prtKernelHyperbolicTangent < prtKernel
    % prtKernelHyperbolicTangent  Hyperbolic tangent kernel
    %
    %  kernelObj = prtKernelHyperbolicTangent; Generates a kernel object
    %  implementing a hyperbolic tangent.  Kernel objects are widely used
    %  in several prt classifiers, such as prtClassRvm and prtClassSvm.
    %  Hyperbolic tangent kernels implement the following function for 1 x
    %  N vectors x1 and x2:
    %
    %   k(x1,x2) = tanh(kappa*x1*x2'+c);
    %
    %  KERNOBJ = prtKernelHyperbolicTangent(PROPERTY1, VALUE1, ...) constructs a
    %  prtKernelHyperbolicTangent object KERNOBJ with properties as specified by
    %  PROPERTY/VALUE pairs. prtKernelHyperbolicTangent objects have the following
    %  user-settable properties:
    %
    %   kappa   - Positive scalar value specifying the gain on the inner
    %             product between x1 and x2 (default 1)
    %
    %   c       - Scalar value specifying DC offset in hyperbolic tangent
    %             function
    %
    %  For more information on these kernels, please refer to:
    %   
    %  http://en.wikipedia.org/wiki/Support_vector_machine#Non-linear_classification
    %
    %  prtKernelHyperbolicTangent objects inherit the TRAIN, RUN, and AND
    %  methods from prtKernel.
    %
    %  % Example:
    %  ds = prtDataGenBimodal;
    %
    %  k1 = prtKernelHyperbolicTangent;
    %  k2 = prtKernelHyperbolicTangent('kappa',2);
    %   
    %  k1 = k1.train(ds); % Train
    %  g1 = k1.run(ds); % Evaluate
    %
    %  k2 = k2.train(ds); % Train
    %  g2 = k2.run(ds); % Evaluate
    %
    %  subplot(2,2,1); imagesc(g1.getObservations);  %Plot the results
    %  subplot(2,2,2); imagesc(g2.getObservations);
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc, prtKernelDirect,
    %   prtKernelPolynomial, prtKernelRbf, prtKernelRbfNdimensionScale, 

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
        name = 'Hyperbolic Tangent Kernel'; % Hyperbolic Tangent Kernel
        nameAbbreviation = 'TANH';  % TANH
    end
    properties
        kappa = 1;    % polynomial order
        c = 0;    % offset
    end

    
    methods
        function obj = set.kappa(obj,value)
            assert(isscalar(value) && value > 0,'kappa parameter must be scalar and > 0, value provided is %s',mat2str(value));
            obj.kappa = value;
        end
        
        function obj = set.c(obj,value)
            assert(isscalar(value),'c parameter must be scalar, value provided is %s',mat2str(value));
            obj.c = value;
        end
        
        function obj = prtKernelHyperbolicTangent(varargin)
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
                gram = prtKernelHyperbolicTangent.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,Obj.kappa,Obj.c);
                dsOut = ds.setObservations(gram);
            end
        end
        
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,kappa,c)
            [n1, d] = size(x); %#ok<ASGLU>
            [n2, nin] = size(y); %#ok<ASGLU>
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            gram = tanh(kappa*x*y'+c);
        end
    end
end
