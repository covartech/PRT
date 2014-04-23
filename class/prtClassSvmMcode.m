classdef prtClassSvmMcode < prtClass
    % prtClassSvmMcode  Support vector machine classifier (M-Code
    %   Implementation)
    %
    %    CLASSIFIER = prtClassSvmMcode returns a support vector machine classifier
    %
    %    CLASSIFIER = prtClassSvmMcode(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassSvmMcode object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassSvmMcode object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    c      - Slack variable weight 
    %    tol    - tolerance on learning updates 
    %
    %    The following properties are read-only.
    %
    %    alpha  - Vector of support vector machine weights
    %    beta   - Support vector machine DC offset
    %
    %    For information on relevance vector machines, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/Support_vector_machine
    %
    %    The prtClassSvmMcode object makes use of the sequential minimal
    %    optimization as described in Reference:
    %
    %     J. Platt, Sequential Minimal Optimization: A Fast Algorithm
    %     for Training Support Vector Machines, Microsoft Research Technical
    %     Report MSR-TR-98-14, (1998).
    %
    %    A prtClassSvmMcode object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtClass.
    %
    %    Note: prtClassSvmMcode is provided as a research and development tool;
    %    it is coded entirely in M-code, and the SMO code is un-optimized.
    %    For speed and performance, we receommend using prtClassLibSvm.
    %
    %    Example:
    %
    %    TestDataSet = prtDataGenUnimodal;      % Create some test and
    %    TrainingDataSet = prtDataGenUnimodal;  % training data
    %    classifier = prtClassSvmMcode;              % Create a classifier
    %    classifier = classifier.train(TrainingDataSet);    % Train
    %    classified = run(classifier, TestDataSet);         % Test
    %    subplot(2,1,1);
    %    classifier.plot;
    %    subplot(2,1,2);
    %    [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %    h = plot(pf,pd,'linewidth',3);
    %    title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass

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


    
    properties (SetAccess=private)
        name = 'Support Vector Machine'  % Support Vector Machine
        nameAbbreviation = 'SVM'         % SVM
        isNativeMary = false;  % False
    end
    
    properties
        
        c = 1; % Slack parameter
        tol = 0.00001;  % Tolerance
        kernels = prtKernelRbfNdimensionScale;  % Kernels
    end
    properties (SetAccess = 'protected',GetAccess = 'public')
        alpha % Vector of support vector machine weights
        beta % Support vector machine DC offset
        sparseKernels   % Trained kernels
        sparseAlpha
    end
    
    methods
        
        function Obj = set.kernels(Obj,val)
            assert(numel(val)==1 &&  isa(val,'prtKernel'),'prt:prtClassSvmMcode:kernels','kernels must be a prtKernel');
            Obj.kernels = val;
        end
        
        function Obj = set.c(Obj,val)
            assert(isscalar(val) && isnumeric(val) && val > 0,'prt:prtClassSvmMcode:c','c must be a scalar greater than 0, but value provided is %s',mat2str(val));
            Obj.c = val;
        end
        
        function Obj = set.tol(Obj,val)
            assert(isscalar(val) && isnumeric(val) && val > 0,'prt:prtClassSvmMcode:tol','tol must be a scalar greater than 0, but value provided is %s',mat2str(val));
            Obj.tol = val;
        end
        
        function Obj = prtClassSvmMcode(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            % Train (center) the kernels at the trianing data (if
            % necessary)
            %             obj.trainedkernels = cell(size(obj.kernels));
            %             for ikernel = 1:length(obj.kernels);
            %                 obj.trainedkernels{ikernel} = initializekernelarray(obj.kernels{ikernel},dataset);
            %             end
            %             obj.trainedkernels = cat(1,obj.trainedkernels{:});
            %             gram = prtkernelgrammmatrix(dataset,obj.trainedkernels);
            
            localKernels = Obj.kernels.train(DataSet);
            gram = localKernels.run_OutputDoubleArray(DataSet);
            
            if size(gram,1) ~= size(gram,2)
                error('prtClassSvmMcode:invalidKernelMatrix','prtClassSvmMcode requires a square gram matrix, as generated by a single, symmetric kernel object, where k(xi,xj) = k(xj,xi).  The specified kernel output a gram matrix of size %s.',mat2str(size(gram)));
            end
            
            %Check y-labels
            yZeroOne = DataSet.getBinaryTargetsAsZeroOne;
            [Obj.alpha,Obj.beta] = prtUtilSmo(DataSet.getX,yZeroOne,gram,Obj.c,Obj.tol);
            
            relevantIndices = find(Obj.alpha);
            Obj.sparseKernels = localKernels.retainKernelDimensions(relevantIndices);
            Obj.sparseAlpha = Obj.alpha(relevantIndices);
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            
            memChunkSize = 1000; % Should this be moved somewhere?
            n = DataSet.nObservations;
            
            DataSetOut = prtDataSetClass(zeros(n,1));
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSetClass(DataSet.getObservations(cI,:));
                gram = Obj.sparseKernels.run_OutputDoubleArray(cDataSet);
                %gram = prtKernelGrammMatrix(cDataSet,Obj.trainedKernels);
                
                y = gram*Obj.sparseAlpha - Obj.beta;
                DataSetOut = DataSetOut.setObservations(y, cI);
            end
        end
        
    end
    methods
        function varargout = plot(Obj)
            % plot - Plot output confidence of the prtClassSvmMcode object
            %
            %   CLASS.plot plots the output confidence of the prtClassSvmMcode
            %   object. The dimensionality of the dataset must be 3 or
            %   less, and verboseStorage must be true.
            
            HandleStructure = plot@prtClass(Obj);
            
            % Plot the kernels
            hold on            
            Obj.sparseKernels.plot();
            hold off
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
    end
    
end
