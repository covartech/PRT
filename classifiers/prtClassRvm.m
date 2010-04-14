classdef prtClassRvm < prtClass
    % DataSet = prtDataBimodal;
    % RVM = train(prtClassRVM, DataSet);
    % plot(RVM)
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Relevance Vector Machine'
        nameAbbreviation = 'RVM'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
    end
    
    properties
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        kernels = {prtKernelDc, prtKernelRbf};
    
        % Estimated Parameters
        beta = [];
        sparseBeta = [];
        sparseKernels = {};
        
        % Learning algorithm
        LearningConverged = 0;
        LearningMaxIterations = 1000;
        LearningBetaConvergedTolerance = 1e-3;
        LearningBetaRelevantTolerance = 1e-3;
    end
    
    methods
        
        function Obj = prtClassFld(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected)
        
        function Obj = trainAction(Obj,DataSet)
            warningState = warning;
            %warning off MATLAB:nearlySingularMatrix
            
            if ~DataSet.isBinary
                error('prt:prtClassRvm:nonBinaryData','prtClassRvm requires a binary data set');
            end
            
            y = DataSet.getTargets();
            y(y == 0) = -1;     % Req'd for algorithm
            
            % Train (center) the kernels at the trianing data (if
            % necessary)
            trainedKernels = cell(size(Obj.kernels));
            for iKernel = 1:length(Obj.kernels);
                trainedKernels{iKernel} = initializeKernelArray(Obj.kernels{iKernel},DataSet);
            end
            trainedKernels = cat(1,trainedKernels{:});
            
            gramm = prtKernelGrammMatrix(DataSet,trainedKernels);
            nBasis = size(gramm,2);
            
            sigmaSquared = eps;
            
            %Check to make sure the problem is well-posed.  This can be fixed either
            %with changes to kernels, or by regularization
            G = gramm'*gramm;
            while rcond(G) < 1e-6
                if sigmaSquared == eps
                    warning('prt:prtClassRvm:illConditionedG','RVM initial G matrix ill-conditioned; regularizing diagonal of G to resolve; this can be modified by changing kernel parameters\n');
                end
                G = (sigmaSquared*eye(nBasis) + gramm'*gramm);
                sigmaSquared = sigmaSquared*2;
            end
            Obj.beta = G\gramm'*y;
            
            u = diag(abs(Obj.beta));
            relevantIndices = 1:size(gramm,2);
            
            h1Ind = y == 1;
            h0Ind = y == -1;
            for iteration = 1:Obj.LearningMaxIterations
                
                %%%%
                %%See: Figueiredo: "Adaptive Sparseness For Supervised Learning"
                %%%%
                uK = u(relevantIndices,relevantIndices);
                grammK = gramm(:,relevantIndices);
                
                S = gramm*Obj.beta;
                S(h1Ind) = S(h1Ind) + normpdf(S(h1Ind))./(1-normcdf(-S(h1Ind)));
                S(h0Ind) = S(h0Ind) - normpdf(S(h0Ind))./(normcdf(-S(h0Ind)));
                
                beta_OLD = Obj.beta;
                
                A = (eye(size(uK)) + uK*(grammK'*grammK)*uK);
                B = uK*(grammK'*S);    %this is correct - see equation (21)
                
                Obj.beta(relevantIndices,1) = uK*(A\B);
                
                % Remove irrelevant vectors
                relevantIndices = find(abs(Obj.beta) > max(abs(Obj.beta))*Obj.LearningBetaRelevantTolerance);
                irrelevantIndices = abs(Obj.beta) <= max(abs(Obj.beta))*Obj.LearningBetaRelevantTolerance;
                
                Obj.beta(irrelevantIndices,1) = 0;
                u = diag(abs(Obj.beta));
                
                %check tolerance for basis removal
                TOL = norm(Obj.beta-beta_OLD)/norm(beta_OLD);
                if TOL < Obj.LearningBetaConvergedTolerance
                    Obj.LearningConverged = true;
                    break;
                end
            end
            
            % Make sparse represenation
            Obj.sparseBeta = Obj.beta(relevantIndices,1);
            Obj.sparseKernels = trainedKernels(relevantIndices);
            
            % Very bad training
            if isempty(Obj.sparseBeta)
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
                
            memChunkSize = 1000; % Should this be moved somewhere?
            n = DataSet.nObservations;
            
            DataSetOut = prtDataSetUnLabeled(zeros(n,1));
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSet(DataSet.getObservations(cI,:));
                gramm = prtKernelGrammMatrix(cDataSet,Obj.sparseKernels);
                
                DataSetOut = DataSetOut.setObservations(normcdf(gramm*Obj.sparseBeta), cI);
            end
        end
        
        function imageHandle = plotGriddedEvaledClassifier(Obj, DS, linGrid, gridSize, cMap)
            
            % Call the original plot function
            imageHandle = plotGriddedEvaledClassifier@prtClass(Obj, DS, linGrid, gridSize, cMap);
            
            holdState = ishold;
            hold on;
            for iKernel = 1:length(Obj.sparseKernels)
                classifierPlot(Obj.sparseKernels{iKernel});
                %classifierText(Obj.sparseKernels{iKernel});
            end
            if ~holdState
                hold('off')
            end
            
            
        end
    end
end