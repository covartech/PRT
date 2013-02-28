classdef prtClassSvmPegasos < prtClass
    % prtClassSvmPegasos  Support vector machine classifier
    %   Learned using the Pegasos algorithm
    %
    %   Pegasos: Primal Estimated sub-GrAdient SOlver for SVM
    %       Shalev-Shwartz, Yoram Singer, Nathan Srebro, 2007
    %
    %   CLASSIFIER = prtClassSvmPegasos returns a support vector machine
    %       classifier
    %
    %   CLASSIFIER = prtClassSvmPegasos(PROPERTY1, VALUE1, ...) constructs
    %   a prtClassSvmPegasos object CLASSIFIER with properties as specified
    %   by PROPERTY/VALUE pairs.
    %
    %   A prtClassSvmPegasos object inherits all properties from the
    %   abstract class prtClass. In addition is has the following
    %   properties:
    %
    %   kernels                - A cell array of prtKernel objects specifying
    %                            the kernels to use
    %
    %   A prtClassSvmPegasos also has the following read-only properties:
    %
    %   beta               - The regression weights, estimated during training
    %   sparseBeta         - The sparse regression weights, estimated during
    %                        training
    %   sparseKernels      - The sparse regression kernels, estimated during
    %                        training
    %
    %
    %   A prtClassSvmPegasos object inherits the TRAIN, RUN, CROSSVALIDATE
    %   and KFOLDS methods from prtAction. It also inherits the PLOT method
    %   from prtClass.
    %
    %   Example:
    %
    %   TestDataSet = prtDataGenUnimodal;      % Create some test and
    %   TrainingDataSet = prtDataGenUnimodal;  % training data
    %   classifier = prtClassSvmPegasos;       % Create a classifier
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   % Plot the results
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %   % Example 2, using a different kernel 
    %
    %   TestDataSet = prtDataGenUnimodal;      % Create some test and
    %   TrainingDataSet = prtDataGenUnimodal;  % training data
    %   classifier = prtClassRvm;              % Create a classifier
    % 
    %   % Create a prtKernelSet object with a different pair of
    %   % prtKernels and assign them to the classifier
    %   kernSet = prtKernelDirect & prtKernelRbf;
    %   classifier.kernels = kernSet;
    %
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   % Plot
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    % 
    %   See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %   prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %   prtClassPlsda, prtClassFld, prtClassRvmFigueiredo, prtClassRvmSequential, prtClassGlrt,  prtClass

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
        name = 'Support Vector Machine'  % Relevance Vector Machine
        nameAbbreviation = 'SVM'           % RVM
        isNativeMary = false;  % False
    end
    
    properties
        kernels = prtKernelDc & prtKernelDirect;  % The kernels to be used
        
        nMaxIterations = 1e4; % T
        nObservationsPerSubGradient = 50; %k
        lambda = 1e-4;
        weightChangeConvergenceTolerance = 1e-6;
    end
    
    properties
        beta = [];    % Regression weights
        sparseBeta = [];  % Sparse Beta
        sparseKernels = {};  % Sparse Kernel array
    end
        
    methods
        
        function self = prtClassSvmPegasos(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function varargout = plot(Obj)
            % plot - Plot output confidence of the prtClassRvm object
            %
            %   CLASS.plot plots the output confidence of the prtClassRvm
            %   object. The dimensionality of the dataset must be 3 or
            %   less, and verboseStorage must be true.
            
            HandleStructure = plot@prtClass(Obj);
            
            holdState = get(gca,'nextPlot');
            hold on;
            Obj.sparseKernels.plot;
            set(gca, 'nextPlot', holdState);
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,ds)
            
            localKernels = self.kernels.train(ds);
            gram = localKernels.run_OutputDoubleArray(ds);
            
            nObservations = ds.nObservations;
            nFeatures = size(gram,2);
            w = randn(1,nFeatures);
            w = w./norm(w,1)/sqrt(self.lambda);
            
            y = ds.getTargetsAsBinaryMatrix;
            y = y(:,2);
            y(y==0) = -1;
            
            inverseSqrtLambda = 1./sqrt(self.lambda);
            
            for t = 2:self.nMaxIterations
                oldW = w;
                etaT = 1/(self.lambda*t);
                
                cInds = prtRvUtilRandomSample(nObservations, self.nObservationsPerSubGradient);
                
                At = gram(cInds,:);
                yt = y(cInds);
                
                AtPlusInds = (yt.*(At*w'))<1;
                
                AtPlus = At(AtPlusInds,:);
                ytPlus = yt(AtPlusInds);
                
                wtPlusOneHalf = (1-1/t)*w + etaT./self.nObservationsPerSubGradient*(ytPlus'*AtPlus);
                
                cScale = min(1,inverseSqrtLambda./norm(wtPlusOneHalf));
                w = cScale*wtPlusOneHalf;
                
                if (norm(w-oldW)/nFeatures) < self.weightChangeConvergenceTolerance
                    break
                end
                
            end

            self.beta = w';
            
            %cRelevant = true(size(self.beta));
            cRelevant = abs(self.beta)>self.lambda;
            
            % Make sparse represenation
            self.sparseBeta = self.beta(cRelevant,1);
            self.sparseKernels = localKernels.retainKernelDimensions(cRelevant);
                        
            % Very bad training
            if isempty(find(cRelevant,1));
                warning('prt:prtClassRvm:NoRelevantFeatures','No relevant features were found during training.');
            end
            
        end
        
        function ds = runAction(self,ds)
            
            if isempty(self.sparseBeta)
                ds = ds.setObservations(nan(ds.nObservations,ds.nFeatures));
                return
            end
            
            n = ds.nObservations;
            
            largestMatrixSize = prtOptionsGet('prtOptionsComputation','largestMatrixSize');
            
            memChunkSize = max(floor(largestMatrixSize/length(self.sparseBeta)),1);
            
            out = zeros(n,1);
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDs = prtDataSetClass(ds.getObservations(cI,:));
                
                gram = self.sparseKernels.run(cDs);
                
                out(cI) = gram.getObservations*self.sparseBeta;
            end
            
            ds = ds.setObservations(out);
        end
    end

    methods (Access=protected, Hidden = true)
 
        function y = getMinusOneOneTargets(Obj, DataSet) %#ok<MANU>
            yMat = double(DataSet.getTargetsAsBinaryMatrix());
            y = nan(size(yMat,1),1);
            y(yMat(:,1) == 1) = -1;
            y(yMat(:,2) == 1) = 1;
        end
    end
end
