classdef prtPreProcDeepLearningV1 < prtPreProc
    % prtPreProcDeepLearningV1
    % See:
    %
    %  http://ai.stanford.edu/~ang/papers/nips07-sparsedeepbeliefnetworkv2.pdf
    % Lee, H., Ekanadham, C., & Ng, A. Y. (2008). Sparse deep belief
    % network model for visual area V2. Advances in Neural Information
    % Processing Systems
    %
    properties (SetAccess=private)
        name = 'DeepLearningV1' % Fisher Linear Discriminant
        nameAbbreviation = 'DeepLearn'            % FLD
        isNativeMary = true;  % False
    end
    
    properties
        inputLayer = 'normal';      % or binary
        outputMode = 'continuous';  %
        
        layerSpec = 100;        % 1 x nLayers - number of outputs from each layer
        maxIter = 10000;        % 
        bootstrapOnIter = 1000; % or 0
        
        gradientStepSize = 0.01;
        pcaPreProc = prtPreProcPca('nComponents',70);
        sigmaNormal = 0.1;
        
        enforceSparsity = true;
        goalSparseP = 0.02;
        sparseLambda = 10;
        
        layerStruct = struct;
        
        useMeanFieldApprox = false;
    end
            
    methods
        
        function self = prtPreProcDeepLearningV1(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            dsIn = dataSet;
            for stageIndex = 1:length(self.layerSpec)
                nNeurons = self.layerSpec(stageIndex);
                
                if stageIndex == 1
                    runPca = ~isempty(self.pcaPreProc);
                    if runPca
                        self.pcaPreProc = self.pcaPreProc.train(dsIn);
                        dsIn = self.pcaPreProc.run(dsIn);
                    end
                    self.layerStruct = struct('W',randn(dsIn.nFeatures,nNeurons),...
                    'c',randn(size(dsIn.X,2),1),'b',randn(nNeurons,1));
                else
                    self.layerStruct(stageIndex) = struct('W',randn(dsIn.nFeatures,nNeurons),...
                        'c',randn(size(dsIn.X,2),1),'b',randn(nNeurons,1));
                end
                
                [self.layerStruct(stageIndex),phv] = self.learnStage(dsIn,self.layerStruct(stageIndex));
                dsIn.X = phv;
            end
            
        end
        
        function [stage,phv] = learnStage(self,ds,stage)
            
            b = stage.b;
            W = stage.W;
            c = stage.c;
            gradStep = self.gradientStepSize;
            sigma = self.sigmaNormal;
            
            for iter = 1:self.maxIter
                
                dsBoot = ds.bootstrap(1000);
                X = dsBoot.X;
                
                % P(h|v) 
                phv = prtUtilLogisticSigmoid(1/sigma.^2.*(bsxfun(@plus,b',X*W)));
                phvorig = phv;
                if ~self.useMeanFieldApprox
                    phv = rand(size(phv)) < phv;
                end
                
                switch self.inputLayer
                    case 'normal'
                        % Gibbs sample v|h: pvh ~ p(v|h)
                        pvh = bsxfun(@plus,c',phv*W');
                        if ~self.useMeanFieldApprox
                            pvh = pvh + randn(size(pvh))*sigma;
                        end
                    otherwise
                        pvh = prtUtilLogisticSigmoid(bsxfun(@plus,c',phv*W'));
                        if ~self.useMeanFieldApprox
                            pvh = rand(size(pvh)) < phv;
                        end
                end
                
                % Gibbs sample h|v, using pvh
                phv2 = prtUtilLogisticSigmoid(1/sigma.^2.*(bsxfun(@plus,b',pvh*W)));
                phv2 = rand(size(phv2)) < phv2;
                
                % Gibbs sample v|h2: 
                switch self.inputLayer
                    case 'normal'
                        % Gibbs sample v|h: pvh ~ p(v|h)
                        pvh2 = bsxfun(@plus,c',phv2*W');
                        pvh2 = pvh2 + randn(size(pvh2))*sigma;
                    otherwise
                        pvh2 = prtUtilLogisticSigmoid(bsxfun(@plus,c',phv2*W'));
                        pvh2 = rand(size(pvh2)) < pvh2;
                end
                
                expectData = ((X'*phv) - (pvh2'*phv2))/size(X,1);
                W = W + gradStep*expectData;
                b = b + gradStep*(mean(phv) - mean(phv2))';
                c = c + gradStep*(mean(X) - mean(pvh2))';
                
                if self.enforceSparsity
                    a = self.goalSparseP - mean(phvorig);
                    
                    % See footnote #3
                    %                     a2 = -mean(phvorig.*(1-phvorig));
                    %                     % Alternative:
                    %                     %     a2 = -mean(phv2orig.*(1-phv2orig));
                    %                     a3 = X./sigma.^2;
                    %                     ddw = squeeze(mean(bsxfun(@times,a3,reshape(a.*a2,[1 1 nNeurons])),1));
                    %                     W = W + self.sparseLambda*ddw;
                    ddb = -a.*mean(phvorig.*(1-phvorig).*1/sigma^2);
                    ddb = ddb(:);
                    b = b - self.sparseLambda*ddb;
                end
                
                plotting = ~mod(iter,50);
                if plotting
                    if ~isempty(self.pcaPreProc)
                        try
                            xOut = self.pcaPreProc.reconstruct(prtDataSetClass(W'));
                            Wplot = xOut.X';
                        catch
                            Wplot = W;
                        end
                    else
                        Wplot = W;
                    end
                    
                    %                     imgSize = [28 28];
                    imgSize = [61 25];
                    nImgs = sqrt(size(W,2));
                    try
                        wNan = col2im(Wplot,imgSize,nImgs*imgSize,'distinct');
                        imagesc(wNan);
                        title(iter);
                    catch ME
                        imagesc(Wplot);
                        title(iter);
                    end
                    drawnow;
                end
            end
            phv = prtUtilLogisticSigmoid(1/sigma.^2.*(bsxfun(@plus,b',ds.X*W)));
            stage.b = b;
            stage.W = W;
            stage.c = c;
        end
        
        
        function dataSet = runAction(self,dataSet)
            
            runPca = ~isempty(self.pcaPreProc);
            if runPca
                dataSet = self.pcaPreProc.run(dataSet);
            end
            X = dataSet.X;
            for stageIndex = 1:length(self.layerSpec)
                b = self.layerStruct(stageIndex).b;
                W = self.layerStruct(stageIndex).W;
                sigma = self.sigmaNormal;
                X = 1/sigma.^2.*(bsxfun(@plus,b',X*W));
                if stageIndex == length(self.layerSpec) && strcmpi(self.outputMode,'continuous')
                    break;
                end
                X = prtUtilLogisticSigmoid(X);
            end
            dataSet.X = X;
            dataSet.featureNames = prtUtilCellPrintf('Deep %d',num2cell(1:size(X,2)));
        end
    end
end
