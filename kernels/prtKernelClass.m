classdef prtKernelClass < prtKernel
    % prtKernelClass  prtClassifier Kernel
    %
    %  k = prtKernelClass Generates a kernel object implementing a
    %  classifier function.  Kernel objects are widely used in several
    %  prt classifiers, such as prtClassRvm and prtClassSvm.  Class kernels
    %  output the results of running a classifier on the input data set:
    %
    %   k(x1) = classifier.run(prtDataSetClass(x1));
    %
    %  k = prtKernelClass(PROPERTY1, VALUE1, ...) constructs a
    %  prtKernelClass object k with properties as specified by
    %  PROPERTY/VALUE pairs. prtKernelClass objects have the following
    %  user-settable properties:
    %
    %   baseClassifier   - a prtClass object.
    %
    %   prtKernelClass objects inherit the TRAIN and RUN methods from prtKernel.
    %
    % Example:
    %   dataSet = prtDataGenUnimodal;
    %   classifier = prtClassRvm;              % Create a classifier
    %   classifierV2 = classifier;
    %
    %   classifier.kernels = prtKernelDc & prtKernelRbf;
    %   classifierV2.kernels = prtKernelDc & prtKernelRbf & prtKernelClass;
    %
    %   classifier = classifier.train(dataSet);    % Train
    %   classifierV2 = classifierV2.train(dataSet);
    %
    %   % Plot
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   classifierV2.plot;
    %
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc, prtKernelDirect,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial,
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
        name = 'Classifier Kernel';   % DC Kernel
        nameAbbreviation = 'ClassKern';   % DCKern
    end
    
    properties (Access = 'protected', Hidden = true)
        isRetained = true;
    end
    properties
        baseClassifier = prtClassPlsda;
        classifier
    end
    
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,ds)
            self.internalDataSet = ds;
            self.classifier = self.baseClassifier.train(ds);
            self.isTrained = true;
        end
        
        function dsOut = runAction(self,ds)
            if self.isRetained
                dsOut = self.classifier.run(ds);
                if dsOut.nFeatures ~= 1
                    error('prtKernelClass:tooManyOutputs','Error; baseClassifier output more than one feature dimension; prtKernelClass currently only works for binary classifiers on binary data sets');
                end
            else
                dsOut = prtDataSetClass;
            end
            
        end
    end
    
    methods
        function self = prtKernelClass(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        
        function Obj = set.baseClassifier(Obj,value)
            if ~isa(value,'prtClass')
                error('prtKernelClass:set','baseClassifier must be a prtClass object');
            end
            Obj.baseClassifier = value(:);
        end
    end
    
    methods(Hidden = true)
        function varargout = plot(obj)
            varargout{1} = [];
        end
        
        
        function nDimensions = nDimensions(Obj)
            if ~Obj.isTrained
                error('prtKernelClass:nDimensions','Attempt to calculate nDimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            nDimensions = double(Obj.isRetained);
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            if ~Obj.isTrained
                error('prtKernelClass:retainKernelDimensions','Attempt to retain dimensions from an untrained kernel; use kernel.train(ds) to train');
            end
            if islogical(keepLogical) && length(keepLogical) ~= Obj.nDimensions
                error('prtKernelClass:retainKernelDimensions','When using logical indexing for retaining kernels, length of logical vector (%d) must be equal to kernel.nDimensions (%d)',length(keepLogical),Obj.nDimensions);
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
