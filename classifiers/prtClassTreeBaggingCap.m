classdef prtClassTreeBaggingCap < prtClass
    % prtClassTreeBaggingCap - Tree bagging CAP classifier
    %
    % prtClassTreeBaggingCap Properties:
    %
    % prtClassTreeBaggingCap Methods:
    %   prtClassTreeBaggingCap -  Tree bagging CAP constructor
    %   train -  Tree bagging CAP training; see prtAction.train
    %   run -  Tree bagging CAP evaluation; see prtAction.run
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Central Axis Projection'
        nameAbbreviation = 'CAP'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
        
        % Central axis projection weights
        root = [];
        % Decision threshold
        threshold = [];
    end
    
    properties
        % thresholdSampling
        %   thresholdSampling specifies the number of neighbors to consider in the
        %   nearest-neighbor voting.
        nTrees = 100;
        
        nFeatures = 2;
        featureSelectWithReplacement = 1;
        
        bootStrapDataAtNodes = 0;
        bootStrapDataAtRoots = 0;
        
        nProcessors = 1;
        
        useMex = 1;
        Memory = struct('nAppend',1000);
        
        CapClassifier = prtClassCap;
    end
    
    methods
        function Obj = prtClassTreeBaggingCap(varargin)
            %Cap = prtClassTreeBaggingCap(varargin)
            %   The Tree bagging CAP constructor allows the user to use
            % name/property pairs to set public fields of the KNN classifier.
            %
            %   For example:
            %
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected)
        function Obj = trainAction(Obj,DataSet)
            
            if Obj.nProcessors>1
                matlabpool(Obj.nProcessors)
            end
            
            %parfor(i = 1:Obj.nTrees,Obj.nProcessors)
            for i = 1:Obj.nTrees
                treeRoot(i) = generateCAPTree(Obj,DataSet);  %#ok<AGROW>
                
                len = length(find(~isnan(treeRoot(i).W(1,:))));
                treeRoot(i).W = treeRoot(i).W(:,1:len);   %#ok<AGROW>
                treeRoot(i).threshold = treeRoot(i).threshold(:,1:len);  %#ok<AGROW> 
                treeRoot(i).featureIndices = treeRoot(i).featureIndices(:,1:len);  %#ok<AGROW>
                treeRoot(i).treeIndices = treeRoot(i).treeIndices(:,1:len);  %#ok<AGROW>
                treeRoot(i).terminalVote = treeRoot(i).terminalVote(:,1:len);  %#ok<AGROW>
            end
            
            if Obj.nProcessors > 1
                matlabpool close
            end
            Obj.root = treeRoot;
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function tree = generateCAPTree(Obj,DataSet)
            %tree = generateCAPTree(Obj,DataSet)
            
            tree.W = [];
            tree.threshold = [];
            tree.featureIndices = [];
            tree.treeIndices = [];
            tree.terminalVote = [];
            tree.maxReservedLen = 0;
            
            tree.father = 0;
            if Obj.bootStrapDataAtRoots
                DataSet = DataSet.bootstrapByClass;
            end
            tree = recursiveCAPtree(Obj,tree,DataSet,1);
        end
        
        function tree = recursiveCAPtree(Obj,tree,DataSet,index)
            
            if index > tree.maxReservedLen
                tree.W = memorySaverAppendNulls(tree.W,Obj.Memory.nAppend,Obj.nFeatures);
                tree.threshold = memorySaverAppendNulls(tree.threshold,Obj.Memory.nAppend,1);
                tree.featureIndices = memorySaverAppendNulls(tree.featureIndices,Obj.Memory.nAppend,Obj.nFeatures);
                tree.treeIndices = memorySaverAppendNulls(tree.treeIndices,Obj.Memory.nAppend,1);
                tree.terminalVote = memorySaverAppendNulls(tree.terminalVote,Obj.Memory.nAppend,1);
                tree.maxReservedLen = tree.maxReservedLen + Obj.Memory.nAppend;
            end
            
            %Base cases; if there is only one class left, we must return
            if length(unique(DataSet.getTargets)) == 1;
                tree.W(:,index) = inf;  %place holder for completed processing
                tree.treeIndices(index) = tree.father;
                tree.terminalVote(index) = unique(DataSet.getTargets);
                return;
            end
            
            %Choose random subspace projection:
            if Obj.featureSelectWithReplacement  %allow redundant features
                tree.featureIndices(:,index) = ceil(rand([1,Obj.nFeatures])*DataSet.nFeatures)';
                tree.treeIndices(index) = tree.father;
            else
                locInd = randperm(DataSet.nFeatures)'; %do NOT allow redundant features
                tree.featureIndices(:,index) = locInd(1:Obj.nFeatures);
                tree.treeIndices(index) = tree.father;
            end
            
            if Obj.bootStrapDataAtNodes
                DataSetTrain = DataSet.bootstrapByClass;
            else
                DataSetTrain = DataSet;
            end
            DataSetTrain = DataSetTrain.retainFeatures(tree.featureIndices(:,index));
            
            % Generate a CAP classifier;
            TrainedCapClassifier = Obj.CapClassifier.train(DataSetTrain);
            tree.W(:,index) = TrainedCapClassifier.w;
            tree.threshold(:,index) = TrainedCapClassifier.threshold;
            %yOut = double(((tree.W(:,index)'*X(:,tree.featureIndices(:,index))')' - tree.threshold(:,index)) >= 0);
            yOut = run(TrainedCapClassifier,DataSetTrain);
            clear classifier;
            
            ind0 = find(yOut.getObservations == 0);
            ind1 = find(yOut.getObservations == 1);
            
            if isempty(ind0) || isempty(ind1)
                error('Classifier output unique labels');
            end
            
            tree.father = index;
            DataSetLeft = DataSet.retainObservations(ind0);
            tree = recursiveCAPtree(Obj,tree,DataSetLeft,index + 1);
            tree.father = index;
            DataSetRight = DataSet.retainObservations(ind1);
            maxLen = length(find(~isnan(tree.W(1,:))));
            tree = recursiveCAPtree(Obj,tree,DataSetRight,maxLen + 1);
            
            function M = memorySaverAppendNulls(M,nAppend,nFeats)
                M = cat(2,M,nan(nFeats,nAppend));
            end
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            Yout = nan(PrtDataSet.nObservations,length(Obj.root));
            x = PrtDataSet.getObservations;
            for j = 1:PrtDataSet.nObservations
                for i = 1:length(Obj.root);
                    if Obj.useMex
                        Yout(j,i) = prtUtilEvalCAPtreeMEX(Obj.root(i),x(j,:));
                    else
                        Yout(j,i) = prtUtilEvalCAPtree(Obj.root(i),x(j,:));
                    end
                end
            end
            ClassifierResults = prtDataSet(mean(Yout,2));
        end
        
        
    end
end
