classdef prtClassTreeBaggingCap < prtClass
    % prtClassTreeBaggingCap  Tree bagging central axis projection classifier
    %
    %    CLASSIFIER = prtClassTreeBaggingCap Tree bagging central axis
    %    projection classifier.  This classifier is based on the "Random
    %    Forest" classifier described in 
    %
    %    Breiman, Leo (2001). "Random Forests". Machine Learning 45
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
    %
    %    featureSelectWithReplacement - Flag indicating whether or not to
    %                                   do feature selection with 
    %                                   replacement
    %
    %    bootStrapDataAtRoots         - Flag indicating whether or not
    %                                   to bootstrap at roots
    %
    %    useMex                       - Flag indicating wheter or not to
    %                                   use the Mex file for speedup.
    %
    %    fastTraining                 - Flag indicating whether to use
    %                                   "fast" training.  Fast training
    %                                   does not necessarily choose the
    %                                   optimal operating point at each
    %                                   node, but is much faster, and often
    %                                   has competetive (or even superior)
    %                                   cross-validation performance, at
    %                                   the expense of increased
    %                                   tree-length.
	%
	%    computePercIncrMisclassRate  - Flag indicating whether or not to
	%                                   compute percent increase in
	%                                   misclassification rate
    %    
    %
    %  For more information on random tree classifiers, see:
    %   http://en.wikipedia.org/wiki/Random_forest
    %   http://www.stat.berkeley.edu/~breiman/RandomForests/cc_home.htm
    %
    %    A prtClassTreeBaggingCap  object inherits the TRAIN, RUN, 
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits 
    %    the PLOT method from prtClass.
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
    
        name = 'Tree Bagging Central Axis Projection'  %Tree Bagging Central Axis Projection
        nameAbbreviation = 'TBCAP'  % TBCAP
       
        isNativeMary = true;    % False
        
         % Array of Central Axis Projection Trees
        root = [];
		
		percIncrMisclassRate = [];
    end
    
    properties
       
        nTrees = 100; % The number of trees
        
        nFeatures = 2;  % The number of features at each node
        
        featureSelectWithReplacement = true;  % Flag indicating whether or not to do feature selection with replacement
        
        bootStrapDataAtRoots = true; % Flag indicating whether or not to boostrap at roots
        
        useMex = true;     % Flag indicating whether or not to use the Mex file
        
        fastTraining = false; % Whether to truly optimize operating points at each branch (false), or take a rough guess (true)
	    
		computePercIncrMisclassRate = false; % Flag indicating whether or not to compute percent increase in misclassification rate
    end
    properties (Hidden = true)
        eml = true;
        Memory = struct('nAppend',1000); % Used in prtUtilRecursiveCapTree
        trackTreePerformance = false;
        equalizeInstancesPerClass = false;
    end
    
    methods
        function self = set.nTrees(self,val)
            assert(isscalar(val) && isnumeric(val) && val > 0 && val == round(val),'prt:prtClassTreeBaggingCap:nTrees','nTrees must be a scalar integer greater than 0, but value provided is %s',mat2str(val));
            self.nTrees = val;
        end
        function self = set.nFeatures(self,val)
            assert(isscalar(val) && isnumeric(val) && val > 0 && val == round(val),'prt:prtClassTreeBaggingCap:nFeatures','nFeatures must be a scalar integer greater than 0, but value provided is %s',mat2str(val));
            self.nFeatures = val;
        end
        function self = set.featureSelectWithReplacement(self,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassTreeBaggingCap:featureSelectWithReplacement','featureSelectWithReplacement must be a logical value, but value provided is a %s',class(val));
            self.featureSelectWithReplacement = val;
        end
        function self = set.bootStrapDataAtRoots(self,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassTreeBaggingCap:bootStrapDataAtRoots','bootStrapDataAtRoots must be a logical value, but value provided is a %s',class(val));
            self.bootStrapDataAtRoots = val;
        end
        function self = set.useMex(self,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassTreeBaggingCap:useMex','useMex must be a logical value, but value provided is a %s',class(val));
            self.useMex = val;
        end
        function Obj = set.computePercIncrMisclassRate(Obj,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassTreeBaggingCap:computePercIncrMisclassRate','computePercIncrMisclassRate must be a logical value, but value provided is a %s',class(val));
            Obj.computePercIncrMisclassRate = val;
        end
        function self = prtClassTreeBaggingCap(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        function self = trainAction(self,dataSet)
            
			percIncrMisclassRate = zeros(dataSet.nFeatures,1);
			for i = 1:self.nTrees
				
				if self.computePercIncrMisclassRate
					[treeRoot(i),pimcr] = generateCAPTree(self,dataSet);  %#ok<AGROW>
					percIncrMisclassRate = (percIncrMisclassRate*(i-1)+pimcr)/i;
				else
					treeRoot(i) = generateCAPTree(self,dataSet);  %#ok<AGROW>
				end
				
				if i == 1
					treeRoot = repmat(treeRoot,self.nTrees,1);
				end
				
				len = length(find(~isnan(treeRoot(i).W(1,:))));
				treeRoot(i).W = treeRoot(i).W(:,1:len);   %#ok<AGROW>
				treeRoot(i).threshold = treeRoot(i).threshold(:,1:len);  %#ok<AGROW>
				treeRoot(i).featureIndices = treeRoot(i).featureIndices(:,1:len);  %#ok<AGROW>
				treeRoot(i).treeIndices = treeRoot(i).treeIndices(:,1:len);  %#ok<AGROW>
				treeRoot(i).terminalVote = treeRoot(i).terminalVote(:,1:len);  %#ok<AGROW>
			end
			self.percIncrMisclassRate = percIncrMisclassRate;
            
            if self.eml
                wSizes = cellfun(@(x)size(x),{treeRoot.W},'uniformOutput',false);
                wSizes = cat(1,wSizes{:});
                maxWSize = max(wSizes,[],1);
                maxWSize = maxWSize(2);
                for i = 1:length(treeRoot)
                    f = fieldnames(treeRoot);
                    for j = 1:length(f)
                        treeRoot(i).(f{j}) = cat(2,treeRoot(i).(f{j}),nan(size(treeRoot(i).(f{j}),1),maxWSize-size(treeRoot(i).(f{j}),2))); %#ok<AGROW>
                    end
                end
            end
            
            self.root = treeRoot;
            
        end
        
        function varargout = generateCAPTree(self,dataSet)
			%[tree,percIncMisclassRate] = generateCAPTree(Obj,DataSet)
            
            tree.W = [];
            tree.threshold = [];
            tree.featureIndices = [];
            tree.treeIndices = [];
            tree.terminalVote = [];
            tree.maxReservedLen = 0;
            
            tree.father = 0;
            if self.bootStrapDataAtRoots
                if self.equalizeInstancesPerClass
                    [bootstrapDataSet,chosenObsInds] = dataSet.bootstrapByClass(ceil(median(dataSet.nObservationsByClass)));
                else
    				[bootstrapDataSet,chosenObsInds] = dataSet.bootstrapByClass();
                end
            else
                bootstrapDataSet = dataSet;
            end
            
            if self.fastTraining
                tree = prtUtilRecursiveCapTreeFast(self, tree, bootstrapDataSet.getObservations, logical(bootstrapDataSet.getTargetsAsBinaryMatrix), 1);
            else
                tree = prtUtilRecursiveCapTree(self, tree, bootstrapDataSet.getObservations, logical(bootstrapDataSet.getTargetsAsBinaryMatrix), 1);
            end
			varargout{1} = tree;
			
			if self.computePercIncrMisclassRate
				outOfBagDataSet = dataSet.removeObservations(chosenObsInds);
				misClassRate = zeros(outOfBagDataSet.nFeatures,1);
				for i = 1:outOfBagDataSet.nFeatures
					permutedDataSet = outOfBagDataSet.permuteFeatures(i);
					x = permutedDataSet.getObservations;
					if self.useMex
						[featInd,~] = find(prtUtilEvalCapTreeMex(tree, x, self.dataSetSummary.nClasses)');
					else
						for jSample = 1:permutedDataSet.nObservations
							[featInd,~] = find(prtUtilEvalCAPtree(tree,x(jSample,:),self.dataSetSummary.nClasses)');
						end
					end
					misClassRate(i) = sum(outOfBagDataSet.targets~=(featInd-1))/outOfBagDataSet.nObservations;
				end
				[featInd,~] = find(prtUtilEvalCapTreeMex(tree, outOfBagDataSet.getObservations, self.dataSetSummary.nClasses)');
				nonPermMisclassRate = sum(outOfBagDataSet.targets~=(featInd-1))/outOfBagDataSet.nObservations;
				percIncrMisclassRate = (misClassRate-nonPermMisclassRate)/nonPermMisclassRate;
				varargout{2} = percIncrMisclassRate;
			end
            
        end
        
        function ClassifierResults = runAction(self,PrtDataSet)
            
            Yout = zeros(PrtDataSet.nObservations,self.dataSetSummary.nClasses);
            x = PrtDataSet.getObservations;
            theRoot = self.root;
            
            if self.useMex
                for iTree = 1:self.nTrees
                    treeOut = prtUtilEvalCapTreeMex(theRoot(iTree), x, self.dataSetSummary.nClasses);
                    Yout = Yout + treeOut;
                    
                    if self.trackTreePerformance
                        if iTree == 1
                            treeOutCell = repmat({treeOut},self.nTrees,1);
                        else
                            treeOutCell{iTree} = treeOut;
                        end
                    end
                end
            else
                for jSample = 1:PrtDataSet.nObservations
                    for iTree = 1:self.nTrees
                        Yout(jSample,:) = Yout(jSample,:) + prtUtilEvalCAPtree(theRoot(iTree),x(jSample,:),self.dataSetSummary.nClasses);
                    end
                end
            end
            ClassifierResults = PrtDataSet;
            ClassifierResults.X = Yout/length(theRoot);
            
            if self.trackTreePerformance
                for iTree = 1:self.nTrees;
                    ClassifierResults = ClassifierResults.setObservationInfo(sprintf('tree%05d',iTree),treeOutCell{iTree});
                end
            end
        end
        function Yout = runActionFast(self, X)
            nClasses = self.dataSetSummary.nClasses;
            
            Yout = zeros(size(X,1), nClasses);
            theRoot = self.root;
            
            for iTree = 1:self.nTrees
                Yout = Yout + prtUtilEvalCapTreeMex(theRoot(iTree), X, nClasses);
            end
        end
    end
end
