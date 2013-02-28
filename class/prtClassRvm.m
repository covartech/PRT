classdef prtClassRvm < prtClass
    % prtClassRvm  Relevance vector machine classifier
    %
    %   CLASSIFIER = prtClassRvm returns a relevance vector machine classifier
    %
    %   CLASSIFIER = prtClassRvm(PROPERTY1, VALUE1, ...) constructs a
    %   prtClassRvm object CLASSIFIER with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtClassRvm object inherits all properties from the abstract class
    %   prtClass. In addition is has the following properties:
    %
    %   kernels                - A cell array of prtKernel objects specifying
    %                            the kernels to use
    %   verbosePlot            - Flag indicating whether or not to plot during
    %                            training
    %   verboseText            - Flag indicating whether or not to output
    %                            verbose updates during training
    %   learningMaxIterations  - The maximum number of iterations
    %
    %   A prtClassRvm also has the following read-only properties:
    %
    %   learningConverged  - Flag indicating if the training converged
    %   beta               - The regression weights, estimated during training
    %   sparseBeta         - The sparse regression weights, estimated during
    %                        training
    %   sparseKernels      - The sparse regression kernels, estimated during
    %                        training
    %
    %   For information on relevance vector machines, please
    %   refer to the following URL:
    %
    %   http://en.wikipedia.org/wiki/Relevance_vector_machine
    %
    %   By default, prtClassRvm uses the Laplacian approximation as found
    %   in the paper:
    %
    %   Michael E. Tipping. 2001. Sparse bayesian learning and the
    %   relevance vector machine. J. Mach. Learn. Res. 1 (September 2001),
    %
    %   The code is based on the algorithm in: 
    %
    %   Herbrich, Learning Kernel Classifiers, The MIT Press, 2002
    %   http://www.learning-kernel-classifiers.org/
    %
    %   A prtClassRvm object inherits the TRAIN, RUN, CROSSVALIDATE and
    %   KFOLDS methods from prtAction. It also inherits the PLOT method
    %   from prtClass.
    %
    %   Example:
    %
    %   TestDataSet = prtDataGenUnimodal;      % Create some test and
    %   TrainingDataSet = prtDataGenUnimodal;  % training data
    %   classifier = prtClassRvm;              % Create a classifier
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
        name = 'Relevance Vector Machine'  % Relevance Vector Machine
        nameAbbreviation = 'RVM'           % RVM
        isNativeMary = false;  % False
    end
    
    properties
        kernels = prtKernelDc & prtKernelRbfNdimensionScale;  % The kernels to be used
        
        verboseText = false;  % Whether or not to display text during training
        verbosePlot = false;  % Whether or not to plot during training
        
        learningMaxIterations = 1000;       % The maximum number of iterations
        learningConvergedTolerance = 1e-5;  % Learning tolerance; 
        % at iteration i, if ||if \theta_{i}-\theta_{i-1}|| / length(theta)
        % < learningConvergedTolerance, learning has converged
        
        learningRelevantTolerance = 1e-5;   %Tolerance below which a kernel is marked as irrelevant and removed
        % Tolerance on \theta; if \theta is < learningConvergedTolerance, the kernel is irrelevant and can be ignored
    end
    
    % Estimated Parameters
    properties (GetAccess = public, SetAccess = protected)
        beta = [];    % Regression weights
        sparseBeta = [];  % Sparse Beta
        sparseKernels = {};  % Sparse Kernel array
        learningConverged = false;   % Flag indicating whether or not training convereged
    end
    
    properties
    end
    
    methods
        
        function Obj = prtClassRvm(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.learningMaxIterations(Obj,val)
            if ~prtUtilIsPositiveInteger(val)
                error('prt:prtClassRvm:learningMaxIterations','learningMaxIterations must be a positive integer');
            end
            Obj.learningMaxIterations = val;
        end
        
        function Obj = set.learningConvergedTolerance(Obj,val)
            if ~prtUtilIsPositiveScalar(val)
                error('prt:prtClassRvm:learningConvergedTolerance','learningConvergedTolerance must be a positive scalar');
            end
            Obj.learningConvergedTolerance = val;
        end
        
        function Obj = set.learningRelevantTolerance(Obj,val)
            if ~prtUtilIsPositiveScalar(val)
                error('prt:prtClassRvm:learningRelevantTolerance','learningRelevantTolerance must be a positive scalar');
            end
            Obj.learningRelevantTolerance = val;
        end
        
        function Obj = set.kernels(Obj,val)
            assert(numel(val)==1 &&  isa(val,'prtKernel'),'prt:prtClassRvm:kernels','kernels must be a prtKernel');
            
            Obj.kernels = val;
        end
        
        function Obj = set.verbosePlot(Obj,val)
            assert(isscalar(val) && (islogical(val) || prtUtilIsPositiveInteger(val)),'prt:prtClassRvm:verbosePlot','verbosePlot must be a logical value or a positive integer');
            Obj.verbosePlot = val;
        end
        
        function Obj = set.verboseText(Obj,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassRvm:verboseText','verboseText must be a logical value, but value provided is a %s',class(val));
            Obj.verboseText = val;
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
        
        function Obj = trainAction(Obj,DataSet)
            %Rvm = trainAction(Rvm,DataSet) (Private; see prtClass\train)
            %   Implements Jefferey's prior based training of a relevance
            %   vector machine.  The Rvm output from this function contains
            %   fields "sparseBeta" and "sparseKernels"
            %
            

            assert(DataSet.isBinary,'prtClassRvm Requires a binary dataset');
            
            warningState = warning;
            warning off MATLAB:nearlySingularMatrix
                        
            %Note: do not assume that getTargets returns a double array or
            %values "0" and "1", instead use this:
            y = Obj.getMinusOneOneTargets(DataSet);
            y(y==-1) = 0;
            
            localKernels = Obj.kernels.train(DataSet);
            gram = localKernels.run_OutputDoubleArray(DataSet);
            
            theta = ones(size(gram,2),1);
            Obj.beta = zeros(size(theta));
            deltaThetaNorm = ones(Obj.learningMaxIterations,1)*nan;

            if Obj.verboseText
                fprintf('RVM training with %d possible vectors.\n', size(gram,2));
            end
            
            for iteration = 1:Obj.learningMaxIterations
                
                %%%%
                %%See: Herbrich: Learning Kernel Classifiers, Algorithm 7, Page 328
                %%%%
                
                %check tolerance for basis removal
                cRelevant = theta > Obj.learningRelevantTolerance;
                
                Obj.beta(~cRelevant) = 0;

                cGram = gram(:,cRelevant);
                cTheta = theta(cRelevant);
                cThetaInv = diag(1./cTheta);
                
                if isempty(cGram)
                    error('prt:prtClassRvm:noRelevantVectors','No relevant vectors were retained; this indicates a kernel that is scaled improperly with regards to the classification problem.  Please try choosing a different kernel or modifying the kernel parameters');
                end
                [newBeta, SigmaInvChol] = prtUtilPenalizedIrls(y,cGram,Obj.beta(cRelevant),cThetaInv);
                     
                Obj.beta(cRelevant) = newBeta;
                
                SigmaChol = inv(SigmaInvChol);
                sigma = SigmaChol*SigmaChol'; %#ok<MINV>
               
                zeta = ones(size(diag(cThetaInv))) - (1./cTheta).*diag(sigma);

                previousTheta= theta;
                theta(cRelevant) = Obj.beta(cRelevant).^2./zeta;
                
                deltaThetaNorm(iteration) = norm(previousTheta-theta)./length(theta);

                if ~mod(iteration,Obj.verbosePlot)
                    if DataSet.nFeatures == 2
                        Obj.verboseIterationPlot(DataSet,cRelevant);
                    elseif iteration == 1
                        warning('prt:prtClassRvm','Learning iteration plot can only be produced for training Datasets with 2 features');
                    end
                end
        
                    
                if deltaThetaNorm(iteration) < Obj.learningConvergedTolerance && iteration > 1
                    % Converged
                    
                    Obj.learningConverged = true;
                    
                    if Obj.verboseText
                        fprintf('Convergence reached. Exiting...\n\n');
                    end
                    
                    break;
                end
                
                if Obj.verboseText
                    fprintf('\t Iteration %d: %d RV''s, Convergence tolerance: %g \n',iteration, sum(cRelevant), deltaThetaNorm(iteration));
                end
                
            end
            
            if Obj.verboseText && iteration == Obj.learningMaxIterations
                fprintf('Exiting...Convergence not reached before the maximum allowed iterations was reached.\n\n');
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(cRelevant,1);
            Obj.sparseKernels = localKernels.retainKernelDimensions(cRelevant);
                        
            % Very bad training
            if isempty(find(cRelevant,1));
                warning('prt:prtClassRvm:NoRelevantFeatures','No relevant features were found during training.');
            end
            
            % Reset warning
            warning(warningState);
            
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            
            if isempty(Obj.sparseBeta)
                DataSetOut = DataSet.setObservations(nan(DataSet.nObservations,DataSet.nFeatures));
                return
            end
            
            n = DataSet.nObservations;
            
            largestMatrixSize = prtOptionsGet('prtOptionsComputation','largestMatrixSize');
            
            memChunkSize = max(floor(largestMatrixSize/length(Obj.sparseBeta)),1);
            
            OutputMat = zeros(n,1);
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSetClass(DataSet.getObservations(cI,:));
                
                gram = Obj.sparseKernels.run(cDataSet);
                
                OutputMat(cI) = prtRvUtilNormCdf(gram.getObservations*Obj.sparseBeta);
            end
            
            DataSetOut = prtDataSetClass(OutputMat);
        end
    end

    methods (Access=protected, Hidden = true)
 
        function y = getMinusOneOneTargets(Obj, DataSet) %#ok<MANU>
            yMat = double(DataSet.getTargetsAsBinaryMatrix());
            y = nan(size(yMat,1),1);
            y(yMat(:,1) == 1) = -1;
            y(yMat(:,2) == 1) = 1;
        end
        
        function G = regularizeGramInnerProduct(Obj, gram)
            nBasis = size(gram,2);
            
            sigmaSquared = 1e-6;
            
            %Check to make sure the problem is well-posed.  This can be fixed either
            %with changes to kernels, or by regularization
            G = gram'*gram;
            while rcond(G) < 1e-6
                if sigmaSquared == eps && Obj.verboseText
                    %warning('prt:prtClassRvm:illConditionedG','RVM initial G matrix ill-conditioned; regularizing diagonal of G to resolve; this can be modified by changing kernel parameters\n');
                    fprintf('\n\tRegularizing Gram matrix...\n');
                end
                G = (sigmaSquared*eye(nBasis) + gram'*gram);
                sigmaSquared = sigmaSquared*2;
            end
            
        end
        
        function verboseIterationPlot(Obj,DataSet,relevantIndices)
            DsSummary = DataSet.summarize;
            
            [linGrid, gridSize,xx,yy] = prtPlotUtilGenerateGrid(DsSummary.lowerBounds, DsSummary.upperBounds, Obj.plotOptions); %#ok<ASGLU>
            
            localKernels = Obj.kernels.train(DataSet);
            cKernels = localKernels.retainKernelDimensions(relevantIndices);
            cPhiDataSet = cKernels.run(prtDataSetClass([xx(:),yy(:)]));
            cPhi = cPhiDataSet.getObservations;
            
            confMap = reshape(prtRvUtilNormCdf(cPhi*Obj.beta(relevantIndices)),gridSize);
            imagesc(xx(1,:),yy(:,1),confMap,[0,1])
            colormap(Obj.plotOptions.twoClassColorMapFunction());
            axis xy
            hold on
            plot(DataSet);
            cKernels.plot();
            hold off;
            
            set(gcf,'color',[1 1 1]);
            drawnow;
        end
    end
end
