classdef prtClassRvm2 < prtClass
    
    
    properties (SetAccess=private)
        name = 'Relevance Vector Machine'  % Relevance Vector Machine
        nameAbbreviation = 'RVM'           % RVM
        isNativeMary = false;  % False
    end
    
    properties
        kernels = prtKernelDc2 & prtKernelRbfNdimensionScale2;
        
        learningVerbose = false;
        learningPlot = false;
    end
    
    % Estimated Parameters
    properties (GetAccess = public, SetAccess = protected)
        Sigma = [];
        beta = [];
        sparseBeta = [];
        sparseKernels = {};
        learningConverged = false;
    end
    
    properties (Hidden = true)
        learningMaxIterations = 1000;
        learningConvergedTolerance = 1e-5;
        learningRelevantTolerance = 1e-3;
    end
    
    methods
        
        function Obj = prtClassRvm2(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.kernels(Obj,val)
            if ~isa(val,'prtKernel2')
                error('need prtKernel2');
            end
            Obj.kernels = val;
        end
        
        function Obj = set.learningPlot(Obj,val)
            assert(isscalar(val) && (islogical(val) || prtUtilIsPositiveInteger(val)),'prt:prtClassRvm:learningPlot','learningPlot must be a logical value or a positive integer');
            Obj.learningPlot = val;
        end
        
        function Obj = set.learningVerbose(Obj,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassRvm:learningVerbose','learningVerbose must be a logical value, but value provided is a %s',class(val));
            Obj.learningVerbose = val;
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
            
            warningState = warning;
            warning off MATLAB:nearlySingularMatrix
                        
            %Note: do not assume that getTargets returns a double array or
            %values "0" and "1", instead use this:
            y = Obj.getMinusOneOneTargets(DataSet);
            y(y==-1) = 0;
            
            %gram = Obj.getGram(DataSet);
            localKernels = Obj.kernels.train(DataSet);
            gramDataSet = localKernels.run(DataSet);
            gram = gramDataSet.getObservations;
            clear gramDataSet;
            
            theta = ones(size(gram,2),1);
            Obj.beta = zeros(size(theta));
            deltaThetaNorm = ones(Obj.learningMaxIterations,1)*nan;

            if Obj.learningVerbose
                fprintf('RVM training with %d possible vectors.\n', size(gram,2));
            end
            
            for iteration = 1:Obj.learningMaxIterations
                
                %%%%
                %%See: Herbrich: Learning Kernel Classifiers, Algorithm 7, Page 328
                %%%%
                
                %check tolerance for basis removal
                cRelevant = theta > Obj.learningConvergedTolerance;
                
                Obj.beta(~cRelevant) = 0;

                cGram = gram(:,cRelevant);
                cTheta = theta(cRelevant);
                cThetaInv = diag(1./cTheta);

                [newBeta, SigmaInvChol] = prtUtilPenalizedIrls(y,cGram,Obj.beta(cRelevant),cThetaInv);
                     
                Obj.beta(cRelevant) = newBeta;
                
                SigmaChol = inv(SigmaInvChol);
                sigma = SigmaChol*SigmaChol';
               
                zeta = ones(size(diag(cThetaInv))) - (1./cTheta).*diag(sigma);

                previousTheta= theta;
                theta(cRelevant) = Obj.beta(cRelevant).^2./zeta;
                
                deltaThetaNorm(iteration) = norm(previousTheta-theta)./length(theta);

                if ~mod(iteration,Obj.learningPlot)
                    if DataSet.nFeatures == 2
                        Obj.verboseIterationPlot(DataSet,cRelevant);
                    elseif iteration == 1
                        warning('prt:prtClassRvm','Learning iteration plot can only be produced for training Datasets with 2 features');
                    end
                end
        
                    
                if deltaThetaNorm(iteration) < Obj.learningConvergedTolerance && iteration > 1
                    % Converged
                    
                    Obj.learningConverged = true;
                    
                    if Obj.learningVerbose
                        fprintf('Convergence reached. Exiting...\n\n');
                    end
                    
                    break;
                end
                
                if Obj.learningVerbose
                    fprintf('\t Iteration %d: %d RV''s, Convergence tolerance: %g \n',iteration, sum(cRelevant), deltaThetaNorm(iteration));
                end
                
            end
            
            if Obj.learningVerbose && iteration == Obj.learningMaxIterations
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
    
    methods (Access=protected,Hidden=true)
        
        function y = getMinusOneOneTargets(Obj, DataSet)
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
                if sigmaSquared == eps && Obj.learningVerbose
                    %warning('prt:prtClassRvm:illConditionedG','RVM initial G matrix ill-conditioned; regularizing diagonal of G to resolve; this can be modified by changing kernel parameters\n');
                    fprintf('\n\tRegularizing Gram matrix...\n');
                end
                G = (sigmaSquared*eye(nBasis) + gram'*gram);
                sigmaSquared = sigmaSquared*2;
            end
            
        end
        
        function verboseIterationPlot(Obj,DataSet,relevantIndices)
            DsSummary = DataSet.summarize;
            
            [linGrid, gridSize,xx,yy] = prtPlotUtilGenerateGrid(DsSummary.lowerBounds, DsSummary.upperBounds, Obj.PlotOptions);
            
            %trainedKernelCell = prtKernel.sparseKernelFactory(Obj.kernels,DataSet,relevantIndices);
            %cPhi = prtKernel.runMultiKernel(trainedKernelCell,prtDataSetClass([xx(:),yy(:)]));
            localKernels = Obj.kernels.train(DataSet);
            cKernels = localKernels.retainKernelDimensions(relevantIndices);
            cPhiDataSet = cKernels.run(prtDataSetClass([xx(:),yy(:)]));
            cPhi = cPhiDataSet.getObservations;
            
            confMap = reshape(prtRvUtilNormCdf(cPhi*Obj.beta(relevantIndices)),gridSize);
            imagesc(xx(1,:),yy(:,1),confMap,[0,1])
            colormap(Obj.PlotOptions.twoClassColorMapFunction());
            axis xy
            hold on
            plot(DataSet);
            %             for iRel = 1:length(trainedKernelCell)
            %                 trainedKernelCell{iRel}.classifierPlot();
            %             end
            %             hold off
            hold off;
            
            set(gcf,'color',[1 1 1]);
            drawnow;
            
            % Obj.UserData.movieFrames(iteration) = getframe(gcf);
        end
        
    end
end