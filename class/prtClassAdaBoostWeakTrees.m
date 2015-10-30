classdef prtClassAdaBoostWeakTrees < prtClass
	% prtClassAdaBoostWeakTrees AdaBoost classifier using binary decision trees as
	%    the weak classifiers
	%
	%    CLASSIFIER = prtClassAdaBoostWeakTrees returns a AdaBoost classifier
	%
	%    CLASSIFIER = prtClassAdaBoostWeakTrees(PROPERTY1, VALUE1, ...)
	%    constructs a prtClassAdaBoostWeakTrees object CLASSIFIER with properties as
	%    specified by PROPERTY/VALUE pairs.
	%
	%    A prtClassAdaBoostWeakTrees object inherits all properties from the abstract
	%    class prtClass. In addition is has the following properties:
	%
	%    nTrees     - the number of trees to learn
	%    maxDepth   - the maximum depth of tree
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%    This is just a wrapper for adaBoostTrain and adaBoostApply from
	%    piotr_toolbox
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	%    Description from adaBoostTrain:
	%      Heavily optimized code for training Discrete or Real AdaBoost where the
	%      weak classifiers are decision trees. With multi-core support enabled (see
	%      binaryTreeTrain.m), boosting 256 depth-2 trees over 5,000 features and
	%      5,000 data points takes under 5 seconds, see example below. Most of the
	%      training time is spent in binaryTreeTrain.m.
	%
	%      For more information on how to quickly boost decision trees see:
	%        [1] R. Appel, T. Fuchs, P. Dollár, P. Perona; "Quickly Boosting
	%            Decision Trees – Pruning Underachieving Features Early," ICML 2013.
	%      The code here implements a simple brute-force strategy with the option to
	%      sample features used for training each node for additional speedups.
	%      Further gains using the ideas from the ICML paper are possible. If you
	%      use this code please consider citing our ICML paper.
	%
	%    Example:
	%
	%    TestDataSet = prtDataGenUnimodal;       % Create some test and
	%    TrainingDataSet = prtDataGenUnimodal;   % training data
	%    classifier = prtClassAdaBoostWeakTrees;            % Create a classifier
	%    classifier = classifier.train(TrainingDataSet);    % Train
	%    classified = run(classifier, TestDataSet);         % Test
	%    subplot(2,1,1);
	%    classifier.plot;
	%    subplot(2,1,2);
	%    [pf,pd] = prtScoreRoc(classified,TestDataSet);
	%    h = plot(pf,pd,'linewidth',3);
	%    title('ROC'); xlabel('Pf'); ylabel('Pd');
	%
	%    See also: prtClassAdaBoostFastAuc
	
	% Copyright (c) 2015 CoVar Applied Technologies
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
		name = 'AdaBoost with weak trees'    % AdaBoost
		nameAbbreviation = 'AdaBoostWeakTrees'  % AdaBoost
		isNativeMary = false;   % False
	end
	
	properties (Hidden)
		verbose = false;
	end
	
	properties
		nTrees = 128; % number of trees to learn
		maxDepth = 2; % maximum depth for each tree
	end
	
	properties (SetAccess=protected)
		clf
	end
	
	methods
		% Constructor
		function self = prtClassAdaBoostWeakTrees(varargin)
			self = prtUtilAssignStringValuePairs(self,varargin{:});
		end
		
		function self = set.nTrees(self,val)
			assert(~self.isTrained,'Cannot change properties of trained classifier')
			self.nTrees = val;
		end
		
		function self = set.maxDepth(self,val)
			assert(~self.isTrained,'Cannot change properties of trained classifier')
			self.maxDepth = val;
		end
	end
	
	methods (Access = protected, Hidden = true)
		
		function self = trainAction(self,dataSet)
			
			if ~dataSet.isBinary
				error('prtClassAdaBoostWeakTrees:nonBinaryTraining','Input dataSet for prtClassAdaBoostWeakTrees.train must be binary');
			end
			
			X = dataSet.X;
			Y = dataSet.Y;
			H1 = X(Y==1,:);
			H0 = X(Y==0,:);
			pBoost=struct('pTree',struct('maxDepth',2),...
				'nWeak',self.nTrees);
			self.clf = adaBoostTrain(H0,H1,pBoost);
			
		end
		
		function dataSet = runAction(self,dataSet)
			
			results = adaBoostApply(dataSet.X,self.clf);
			dataSet = dataSet.setObservations(results);
			
		end
		
	end
end
