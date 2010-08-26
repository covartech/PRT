classdef prtClassTreeBaggingCap < prtClass
% prtClassTreeBaggingCap  Tree bagging central axis projection classifier
    %
    %    CLASSIFIER = prtClassTreeBaggingCap Tree bagging central axis
    %    projection classifier
    %
    %    CLASSIFIER = prtClassTreeBaggingCap(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassTreeBaggingCap object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassTreeBaggingCap object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    nTrees                       - The number of trees
    %    nFeatures                    - The number of features
    %    featureSelectWithReplacement - Flag indicating whether or not to
    %                                   do feature selection with 
    %                                   replacement
    %    bootStrapDataAtNodes         - Flag indicating whether or not 
    %                                   to bootstrap at nodes
    %    bootStrapDataAtRoots         - Flag indicating whether or not
    %                                   to bootstrap at roots
    %    nProcessors                  - the number of processors available
    %                                   on the local machine
    %    useMex                       - flag indicating wheter or not to
    %                                   use the Mex file for speedup.
    %    Memory                       - XXX ?
    %    CapClassifier                - The classifier used for central
    %                                   axis projection
    %
    %   XXX NEED Refernece
    %
    %    A prtClassTreeBaggingCap object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;      % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;  % training data
    %     classifier = prtClassTreeBaggingCap;% Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classes  = classified.getX > .5;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
    
    
    % prtClassTreeBaggingCap - Tree bagging CAP classifier
    %
    % prtClassTreeBaggingCap Properties:
    %
    % prtClassTreeBaggingCap Methods:
    %   prtClassTreeBaggingCap -  Tree bagging CAP constructor
    %   train -  Tree bagging CAP training; see prtAction.train
    %   run -  Tree bagging CAP evaluation; see prtAction.run
    
    properties (SetAccess=private)
    
        name = 'Tree Bagging Central Axis Projection'  %Tree Bagging Central Axis Projection
        nameAbbreviation = 'TBCAP'  % TBCAP
        isSupervised = true;   % True
        
       
        isNativeMary = false;    % False
        
        % Central axis projection weights
        root = [];
        
        % Decision threshold
        threshold = [];
    end
    
    properties
        nTrees = 100; % The number of trees
        
        nFeatures = 2;  % The number of features
        featureSelectWithReplacement = 1;  % Flag indicating whether or not to do feature selection with replacement
        
        bootStrapDataAtNodes = true;  % Flag indicating whether or not to boostrap at nodes
        bootStrapDataAtRoots = true; % Flag indicating whether or not to boostrap at roots
        
        nProcessors = 1;  % The number of processors on this machine
        
        useMex = 1;     % Flag indicating whether or not to use the Mex file
        Memory = struct('nAppend',1000); % XXX ?
        
        CapClassifier = prtClassCap; %The classifier used for central axis projection
    end
    
    methods
        function Obj = prtClassTreeBaggingCap(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
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
                DataSet = DataSet.bootstrapByClass();
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
            yOut = run(TrainedCapClassifier,DataSet.retainFeatures(tree.featureIndices(:,index)));
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
            ClassifierResults = prtDataSetClass(mean(Yout,2));
        end
        
        
    end
end
