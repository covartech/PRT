classdef prtClassRvmFigueiredo < prtClassRvm
    % prtClassRvmFigueiredo  Relevance vector machine classifier using a Jefferey's prior
    %
    %    CLASSIFIER = prtClassRvmFigueiredo returns a relevance vector 
    %    machine classifier.
    %
    %    CLASSIFIER = prtClassRvmFigueiredo(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassRvm object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassRvmFigueiredo object inherits all properties from the
    %    abstract class prtClass. In addition is has the following
    %    properties:
    %
    %    kernels            - A cell array of prtKernel objects specifying
    %                         the kernels to use
    %    verbosePlot        - Flag indicating whether or not to plot during
    %                         training
    %    verboseText        - Flag indicating whether or not to output
    %                         verbose updates during training
    %    learningMaxIterations  - The maximum number of iterations
    %
    %    A prtClassRvmFigeiredo also has the following read-only properties:
    %
    %    learningConverged  - Flag indicating if the training converged
    %    beta               - The regression weights, estimated during training
    %    sparseBeta         - The sparse regression weights, estimated during
    %                        training
    %    sparseKernels      - The sparse regression kernels, estimated during
    %                        training
    %
    %   For more informatoin on the Figueiredo algorithm, please refer to
    %   the following reference:
    % 
    %   M. Figueiredo, Adaptive sparseness for supervised learning, 
    %   IEEE PAMI, vol. 25, no. 9 pp.1150-1159, September 2003.  
    %
    %   Training using the Figueiredo algorithm can provide faster
    %   and more robust convergence under some circumstances.
    %
    %   A prtClassRvm object inherits the TRAIN, RUN, CROSSVALIDATE and
    %   KFOLDS methods from prtAction. It also inherits the PLOT method
    %   from prtClass.
    %
    %   % Example
    %   TestDataSet = prtDataGenUnimodal;      % Create some test and
    %   TrainingDataSet = prtDataGenUnimodal;  % training data
    %    %    % Create a classifier with verbose plotting
    %   classifier = prtClassRvmFigueiredo('verbosePlot',true); 
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   % Plot the results
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   % figure
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd'); 
    %
    %   See also prtClass, prtClassRvm, prtClassRvnSequential,
    %   prtRegressRvmSequential

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


    methods
        function Obj = prtClassRvmFigueiredo(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            
            % The default tolerance from prtClassRvm is too low.
            % We increase it here.
            Obj.learningConvergedTolerance = 5e-4;
        end
    end
    
    methods (Access=protected, Hidden = true)
        function Obj = trainAction(Obj,DataSet)
            %Rvm = trainAction(Rvm,DataSet) (Private; see prtClass\train)

            warningState = warning;
            %warning off MATLAB:nearlySingularMatrix
            
            y = Obj.getMinusOneOneTargets(DataSet);
            
            localKernels = Obj.kernels.train(DataSet);
            gram = localKernels.run_OutputDoubleArray(DataSet);
            %gram = Obj.getGram(DataSet);
            
            G = Obj.regularizeGramInnerProduct(gram);
            
            % Initial solution
            Obj.beta = G\gram'*y;
            
            u = diag(abs(Obj.beta));
            relevantIndices = 1:size(gram,2);
            
            h1Ind = y == 1;
            h0Ind = y == -1;
            
            if Obj.verboseText
                fprintf('RVM (Figuerieredo) training with %d possible vectors.\n', size(gram,2));
            end
            
            for iteration = 1:Obj.learningMaxIterations
                
                %%%%
                %%See: Figueiredo: "Adaptive Sparseness For Supervised learning"
                %%%%
                uK = u(relevantIndices,relevantIndices);
                gramK = gram(:,relevantIndices);
                
                S = gram*Obj.beta;
                
                S(h1Ind) = S(h1Ind) + exp(prtRvUtilMvnLogPdf(S(h1Ind)))./(1-prtRvUtilMvnCdf(-S(h1Ind)));
                S(h0Ind) = S(h0Ind) - exp(prtRvUtilMvnLogPdf(S(h0Ind)))./(prtRvUtilMvnCdf(-S(h0Ind)));
                
                beta_OLD = Obj.beta;
                
                A = (eye(size(uK)) + uK*(gramK'*gramK)*uK);
                B = uK*(gramK'*S);    %this is correct - see equation (21)
                
                Obj.beta(relevantIndices,1) = uK*(A\B);
                
                % Remove irrelevant vectors
                relevantIndices = find(abs(Obj.beta) > max(abs(Obj.beta))*Obj.learningRelevantTolerance);
                irrelevantIndices = abs(Obj.beta) <= max(abs(Obj.beta))*Obj.learningRelevantTolerance;
                
                Obj.beta(irrelevantIndices,1) = 0;
                u = diag(abs(Obj.beta));
                
                if ~mod(iteration,Obj.verbosePlot)
                    if DataSet.nFeatures == 2
                        Obj.verboseIterationPlot(DataSet,relevantIndices);
                    elseif iteration == 1
                        warning('prt:prtClassRvmFigueriredo','Learning iteration plot can only be produced for training Datasets with 2 features');
                    end
                end
                
                %check tolerance for basis removal
                TOL = norm(Obj.beta-beta_OLD)/norm(beta_OLD)/length(relevantIndices);
                if Obj.verboseText
                    fprintf('\t Iteration %d: %d RV''s, Convergence tolerance: %g \n', iteration, length(relevantIndices), TOL);
                end
                
                if TOL < Obj.learningConvergedTolerance
                    Obj.learningConverged = true;
                    
                    if Obj.verboseText
                        fprintf('Convergence reached. Exiting...\n\n');
                    end
                    
                    break;
                end
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = localKernels.retainKernelDimensions(relevantIndices);
            
            
            % Very bad training
            if isempty(Obj.sparseBeta)
                warning('prt:prtClassRvm:NoRelevantFeatures','No relevant vectors were found during training.');
            end
            
            % Reset warning
            warning(warningState);
            
        end
    end
end
