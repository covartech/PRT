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
    %    nCapRocSamples               - Number of ROC samples to use in
    %                                   threshold detemination in Cap 
    %                                   classifier (100)
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
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
    properties (SetAccess=private)
    
        name = 'Tree Bagging Central Axis Projection'  %Tree Bagging Central Axis Projection
        nameAbbreviation = 'TBCAP'  % TBCAP
       
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
        
        bootStrapDataAtNodes = false;  % Flag indicating whether or not to boostrap at nodes
        bootStrapDataAtRoots = true; % Flag indicating whether or not to boostrap at roots
        
        nProcessors = 1;  % The number of processors on this machine
        
        useMex = 1;     % Flag indicating whether or not to use the Mex file
        
        nCapRocSamples = 100;
    end
    properties (Hidden = true)
        Memory = struct('nAppend',1000); % XXX ?
    end
    
    methods
        function Obj = set.nTrees(Obj,val)
            assert(isscalar(val) && isnumeric(val) && val > 0 && val == round(val),'prt:prtClassTreeBaggingCap:nTrees','nTrees must be a scalar integer greater than 0, but value provided is %s',mat2str(val));
            Obj.nTrees = val;
        end
        function Obj = set.nFeatures(Obj,val)
            assert(isscalar(val) && isnumeric(val) && val > 0 && val == round(val),'prt:prtClassTreeBaggingCap:nFeatures','nFeatures must be a scalar integer greater than 0, but value provided is %s',mat2str(val));
            Obj.nFeatures = val;
        end
        function Obj = set.featureSelectWithReplacement(Obj,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassTreeBaggingCap:featureSelectWithReplacement','featureSelectWithReplacement must be a logical value, but value provided is a %s',class(val));
            Obj.featureSelectWithReplacement = val;
        end
        function Obj = set.bootStrapDataAtNodes(Obj,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassTreeBaggingCap:bootStrapDataAtNodes','bootStrapDataAtNodes must be a logical value, but value provided is a %s',class(val));
            Obj.bootStrapDataAtNodes = val;
        end
        function Obj = set.nProcessors(Obj,val)
            assert(isscalar(val) && isnumeric(val) && val > 0 && val == round(val),'prt:prtClassTreeBaggingCap:nProcessors','nProcessors must be a scalar integer greater than 0, but value provided is %s',mat2str(val));
            Obj.nProcessors = val;
        end
        function Obj = set.useMex(Obj,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassTreeBaggingCap:useMex','useMex must be a logical value, but value provided is a %s',class(val));
            Obj.useMex = val;
        end
        function Obj = set.nCapRocSamples(Obj,val)
            assert(isscalar(val) && prtUtilIsPositiveInteger(val),'prt:prtClassTreeBaggingCap:nCapRocSamples','useMex must be a scalar counting number, but value provided was %s',mat2str(val));
            Obj.nCapRocSamples = val;
        end
        
        % Obsolete as of Rev 522
        %         function Obj = set.CapClassifier(Obj,val)
        %             assert(isa(val,'prtClassCap'),'prt:prtClassTreeBaggingCap:CapClassifier','CapClassifier must be a prtClassCap, but value provided is a %s',class(val));
        %             Obj.CapClassifier = val;
        %         end
        
        
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
            %tree = recursiveCAPtree(Obj,tree,DataSet,1);
            tree = recursiveCapTree(Obj,tree,DataSet.getObservations,DataSet.getTargets,1);
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            Yout = nan(PrtDataSet.nObservations,length(Obj.root));
            x = PrtDataSet.getObservations;
            theRoot = Obj.root;
            useMex = Obj.useMex;
            
            %This double loop is slow; we need to make this faster (30
            %seconds to evaluate 10000 samples or so, with a moderately
            %sized tree)
            for j = 1:PrtDataSet.nObservations
                for i = 1:length(theRoot);
                    if useMex
                        Yout(j,i) = prtUtilEvalCAPtreeMEX(theRoot(i),x(j,:));
                    else
                        Yout(j,i) = prtUtilEvalCAPtree(theRoot(i),x(j,:));
                    end
                end
            end
            ClassifierResults = prtDataSetClass(mean(Yout,2));
        end
        
        % This function is now in prtPrivate.recursiveCAPtree to avoud
        % object oriented overhead in thousands of recursive calls, which
        % can be slow, as of MATLAB 2010B
        %         function tree = recursiveCAPtree(Obj,tree,DataSet,index)
        %
        %             if index > tree.maxReservedLen
        %                 tree.W = memorySaverAppendNulls(tree.W,Obj.Memory.nAppend,Obj.nFeatures);
        %                 tree.threshold = memorySaverAppendNulls(tree.threshold,Obj.Memory.nAppend,1);
        %                 tree.featureIndices = memorySaverAppendNulls(tree.featureIndices,Obj.Memory.nAppend,Obj.nFeatures);
        %                 tree.treeIndices = memorySaverAppendNulls(tree.treeIndices,Obj.Memory.nAppend,1);
        %                 tree.terminalVote = memorySaverAppendNulls(tree.terminalVote,Obj.Memory.nAppend,1);
        %                 tree.maxReservedLen = tree.maxReservedLen + Obj.Memory.nAppend;
        %             end
        %
        %             %Base cases; if there is only one class left, we must return
        %             if length(unique(DataSet.getTargets)) == 1;
        %                 tree.W(:,index) = inf;  %place holder for completed processing
        %                 tree.treeIndices(index) = tree.father;
        %                 tree.terminalVote(index) = unique(DataSet.getTargets);
        %                 return;
        %             end
        %
        %             %Choose random subspace projection:
        %             if Obj.featureSelectWithReplacement  %allow redundant features
        %                 tree.featureIndices(:,index) = ceil(rand([1,Obj.nFeatures])*DataSet.nFeatures)';
        %                 tree.treeIndices(index) = tree.father;
        %             else
        %                 locInd = randperm(DataSet.nFeatures)'; %do NOT allow redundant features
        %                 tree.featureIndices(:,index) = locInd(1:Obj.nFeatures);
        %                 tree.treeIndices(index) = tree.father;
        %             end
        %
        %             if Obj.bootStrapDataAtNodes
        %                 DataSetTrain = DataSet.bootstrapByClass;
        %             else
        %                 DataSetTrain = DataSet;
        %             end
        %             DataSetTrain = DataSetTrain.retainFeatures(tree.featureIndices(:,index));
        %
        %             % Generate a CAP classifier (w/o PRT)
        %             %             y = DataSet.getBinaryTargetsAsZeroOne;
        %             %             x = DataSet.getObservations;
        %             %             mean0 = mean(DataSet.getObservationsByClassInd(1),1);
        %             %             mean1 = mean(DataSet.getObservationsByClassInd(2),1);
        %             %             w = mean1 - mean0;
        %             %             w = w./norm(w);
        %             %             yOut = (w*x')';
        %             %
        %             %             %figure out the threshold:
        %             %             [pf,pd,~,thresh] = prtScoreRoc(yOut,y,100);
        %             %             pE = prtUtilPfPd2Pe(pf,pd);
        %             %             [minPe,I] = min(pE);
        %             %             thresholdValue = thresh(unique(I));
        %             %             if minPe >= 0.5
        %             %                 w = -w;
        %             %                 [thresholdValue,minPe] = optimizeThreshold(Obj,x,y);
        %             %                 if minPe >= 0.5
        %             %                     warning('Min PE from CAP.trainAction is >= 0.5');
        %             %                 end
        %             %             end
        %             %             thresholdValue = mean(yOut);
        %             %
        %             %             tree.W(:,index) = w(:);
        %             %             tree.threshold(:,index) = thresholdValue;
        %             %
        %             %             yOut = double(yOut >= tree.threshold(:,index));
        %             %             ind0 = find(yOut == 0);
        %             %             ind1 = find(yOut == 1);
        %             %keyboard
        %
        %             % Generate a CAP classifier (with PRT)
        %             TrainedCapClassifier = Obj.CapClassifier.train(DataSetTrain);
        %             tree.W(:,index) = TrainedCapClassifier.w;
        %             tree.threshold(:,index) = TrainedCapClassifier.threshold;
        %             yOut = run(TrainedCapClassifier,DataSet.retainFeatures(tree.featureIndices(:,index)));
        %             clear classifier;
        %             ind0 = find(yOut.getObservations == 0);
        %             ind1 = find(yOut.getObservations == 1);
        %
        %             if isempty(ind0) || isempty(ind1)
        %                 error('Classifier output unique labels');
        %             end
        %
        %             tree.father = index;
        %             DataSetLeft = DataSet.retainObservations(ind0);
        %             tree = recursiveCAPtree(Obj,tree,DataSetLeft,index + 1);
        %             tree.father = index;
        %             DataSetRight = DataSet.retainObservations(ind1);
        %             maxLen = length(find(~isnan(tree.W(1,:))));
        %             tree = recursiveCAPtree(Obj,tree,DataSetRight,maxLen + 1);
        %
        %             function M = memorySaverAppendNulls(M,nAppend,nFeats)
        %                 M = cat(2,M,nan(nFeats,nAppend));
        %             end
        %         end
    end
end
