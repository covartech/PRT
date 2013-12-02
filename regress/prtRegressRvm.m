classdef prtRegressRvm < prtRegress
    % prtRegressRvm  Relevance vector machine regression object
    %
    %   REGRESS = prtRegressRvm returns a prtRegressRvm object
    %
    %    REGRESS = prtRegressRVM(PROPERTY1, VALUE1, ...) constructs a
    %    prtRegressRvm object REGRESS with properties as specified by
    %    PROPERTY/VALUE pairs.
    % 
    %    A prtRegressRvm object inherits all properties from the prtRegress
    %    class. In addition, it has the following properties:
    %
    %   SetAccess = public:
    %    kernels            - A cell array of prtKernel objects specifying
    %                         the kernels to use
    %    verbosePlot        - Flag indicating whether or not to plot during
    %                         training
    %    verboseText        - Flag indicating whether or not to display
    %                         a message during training
    %
    %   SetAccess = private/protected:
    %    learningConverged  - Flag indicating if the training converged
    %    learningResults    - Struct with information about the convergence
    %    beta               - The weights on each of the kernel elements;
    %                         learned during training
    %    Sigma              - The learned covariance
    %    sparseBeta         - The weights on the retained kernel elements;
    %                         learned durning training
    %    sparseKernels      - The retained kernels
    %
    %   This code is based on:
    %       Michael E Tipping, Sparse bayesian learning and the relevance 
    %   vector machine, The Journal of Machine Learning Research, Vol 1.
    %
    %   Also see http://en.wikipedia.org/wiki/Relevance_vector_machine
    % 
    %   A prtRegressionRvm object inherits the PLOT method from the
    %   prtRegress object, and the TRAIN, RUN, CROSSVALIDATE and KFOLDS
    %   methods from the prtAction object.
    %
    %   Example:
    %   
    %   dataSet = prtDataGenNoisySinc;           % Load a prtDataRegress
    %   dataSet.plot;                    % Display data
    %   reg = prtRegressRvm;             % Create a prtRegressRvm object
    %   reg = reg.train(dataSet);        % Train the prtRegressRvm object
    %   reg.plot();                      % Plot the resulting curve
    %   dataSetOut = reg.run(dataSet);   % Run the regressor on the data
    %   hold on;
    %   plot(dataSet.getX,dataSetOut.getX,'c.') % Plot, overlaying the
    %                                           % fitted points with the 
    %                                           % curve and original data
    %   legend('Regression curve','Original Points','Kernel Locations Used',0)
    %
    %
    %   See also prtRegress, prtRegressGP, prtRegressLslr

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
    end
    
    properties
        kernels = prtKernelDc & prtKernelRbfNdimensionScale;
                
        verbosePlot = false;   % Whether or not to plot during training
        verboseText = false;   % Whether or not to plot during training
    end
    
    properties (Hidden = true)
        learningMaxIterations = 1000;  % Maximum number of iteratoins
        learningConvergedTolerance = 1e-6;
        learningRelevantTolerance = 1e-3;
    end
    properties (SetAccess = 'protected',GetAccess = 'public')
        learningConverged = [];% Whether or not the training converged
        
        beta = [];      % Estimated in training
        Sigma = [];     % Estimated in training
        sigma2 = [];    % Estimated in training
        
        sparseBeta = [];% Estimated in training
        sparseKernels = {};% Estimated in training 
    end
    methods
         % Allow for string, value pairs
        function Obj = prtRegressRvm(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.kernels(Obj,val)
            if ~isa(val,'prtKernel')
                error('prt:prtRegressRvm:kernels','kernels must be a prtKernel');
            end
            
            Obj.kernels = val;
        end
        
        function Obj = set.verbosePlot(Obj,val)
            if ~prtUtilIsLogicalScalar(val)
                error('prt:prtRegressRvm:verbosePlot','verbosePlot must be a logical value or a positive integer');
            end
            Obj.verbosePlot = val;
        end
        
        function Obj = set.verboseText(Obj,val)
            if ~prtUtilIsLogicalScalar(val)
                error('prt:prtRegressRvm:verboseText','verboseText must be a logical value or a positive integer');
            end
            Obj.verboseText = val;
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            %Rvm = trainAction(Rvm,DataSet) (Private; see prtClass\train)
            %   Implements Jefferey's prior based training of a relevance
            %   vector machine.  The Rvm output from this function contains
            %   fields "sparseBeta" and "sparseKernels"
            
            warningState = warning;
            
            if DataSet.nTargetDimensions ~= 1
                error('prt:prtRegressRvm:tooManyTargets','prtRegressRvm can only operate on single target data.');
            end
            
            y = DataSet.getTargets(:,1);
            
            localKernels = Obj.kernels.train(DataSet);
            gram = localKernels.run_OutputDoubleArray(DataSet);
            nBasis = size(gram,2);
            
            if Obj.verboseText
                fprintf('RVM training with %d possible vectors.\n', nBasis);
            end
            
            Obj.beta = zeros(nBasis,1);
            
            relevantIndices = true(nBasis,1); % Everybody!
            
            alpha = ones(nBasis,1); % Initialize
            
            Obj.sigma2 = var(y); % A descent guess to start with
            
            for iteration = 1:Obj.learningMaxIterations
                % Given currenet relevant stuff find the weight mean and
                % covariance
                if ~any(relevantIndices)
                    break;
                end
                cPhi = gram(:,relevantIndices);
                A = diag(alpha(relevantIndices));
                
                sigma2Inv = (Obj.sigma2^-1);
                
                SigmaInv = A + sigma2Inv*(cPhi'*cPhi);
                Obj.Sigma = inv(SigmaInv);
                mu = sigma2Inv*(SigmaInv\(cPhi'*y));
                
                % Find the current prediction
                yHat = cPhi*mu;
                
                % Update A
                logAlphaOld = log(alpha(relevantIndices));
                
                cG = 1 - alpha(relevantIndices).*diag(Obj.Sigma);
                alpha(relevantIndices) = cG./(mu.^2);
                
                % Update sigma2
                Obj.sigma2 = norm(y-yHat)./(length(yHat) - sum(cG));
                
                Obj.beta = zeros(nBasis,1);
                Obj.beta(relevantIndices) = mu;
                
                
                %check tolerance for basis removal
                TOL = abs(log(alpha(relevantIndices))-logAlphaOld);
                TOL(isnan(TOL)) = 0; % inf-inf = nan
                
                if Obj.verboseText
                    fprintf('\t Iteration %d: %d RV''s, Convergence tolerance: %g \n',iteration, sum(relevantIndices), max(TOL));
                end
                
                if all(TOL < Obj.learningConvergedTolerance) && iteration > 1
                    Obj.learningConverged = true;
                    
                    if Obj.verboseText
                        fprintf('Convergence reached. Exiting...\n\n');
                    end
                    
                    break;
                end
                % We didn't break so we can contiue on
                % Select relevant stuff
                newRelevantIndices = alpha < 1./Obj.learningRelevantTolerance;
                
                if ~mod(iteration,Obj.verbosePlot)
                    if DataSet.nFeatures == 1
                        Obj.verboseIterationPlot(DataSet,relevantIndices);
                    elseif iteration == 1
                        warning('prt:prtRegressRvm','Learning iteration plot can only be produced for training Datasets with 1 feature.');
                    end
                end
                
                relevantIndices = newRelevantIndices;
            end
            
            if Obj.verboseText && iteration == Obj.learningMaxIterations
                fprintf('Exiting...Convergence not reached before the maximum allowed iterations was reached.\n\n');
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = localKernels.retainKernelDimensions(relevantIndices);
            
            
            % Very bad training
            if isempty(Obj.sparseBeta)
                warning('prt:prtClassRvm:NoRelevantFeatures','No relevant features were found during training.');
            end
            
            % Reset warning
            warning(warningState);
            
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            
            if isempty(Obj.sparseBeta)
                DataSetOut = DataSet.setObservations(zeros(DataSet.nObservations,Obj.dataSetSummary.nTargetDimensions));
                return
            end
            
            memChunkSize = 1000; % Should this be moved somewhere?
            n = DataSet.nObservations;
            
            DataSetOut = prtDataSetRegress(zeros(n,1));
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSetRegress(DataSet.getObservations(cI,:));
                gram = Obj.sparseKernels.run_OutputDoubleArray(cDataSet);
                
                DataSetOut = DataSetOut.setObservations(gram*Obj.sparseBeta, cI);
            end
        end
    end
    
    methods
        function varargout = plot(Obj)
            
            HandleStructure = plot@prtRegress(Obj);
            
            holdState = get(gca,'nextPlot');
            
            % Plot the kernels
            hold on
            %This only plots the x-coordinate... which is weird, but it's
            %all we can do right now b/c kernels don't know about
            %targets...
            Obj.sparseKernels.plot();
            set(gca, 'nextPlot', holdState);
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
    end
    
    methods (Access=protected,Hidden=true)
        function Obj = verboseIterationPlot(Obj,DataSet,relevantIndices)
            DsSummary = DataSet.summarize;
            
            [linGrid, gridSize] = prtPlotUtilGenerateGrid(DsSummary.lowerBounds, DsSummary.upperBounds, Obj.plotOptions);
            
            trainedKernel = train(Obj.kernels, DataSet);
            trainedKernel = trainedKernel.retainKernelDimensions(relevantIndices);
            cPhi = trainedKernel.run_OutputDoubleArray(prtDataSetClass(linGrid));
            
            yHat = reshape(cPhi*Obj.beta(relevantIndices),gridSize);
            
            colors = Obj.plotOptions.colorsFunction(Obj.dataSetSummary.nTargetDimensions);
            lineWidth = Obj.plotOptions.lineWidth;
            plot(linGrid,yHat,'color',colors(1,:),'lineWidth',lineWidth);
            hold on
            plot(DataSet);
            plot(trainedKernel);
            hold off
            drawnow;
        end
    end
end
