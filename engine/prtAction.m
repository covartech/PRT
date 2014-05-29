classdef prtAction
    % prtAction - Base class for many PRT components.
    % 
    %  prtAction is an abstract class and cannot be instantiated.
    %
    %   Classification, regression and feature selection techniques are all
    %   sub-classes of prtAction.
    %
    %   All prtAction objects have the following properties:
    %
    %   name                 - Descriptive name for prtAction object
    %   nameAbbreviation     - Shortened name for prtAction object
    %   isTrained            - Indicates whether the current prtAction 
    %                          object has been trained                          
    %   isCrossValidateValid - Flag indicating whether or not
    %                          cross-validation is a valid operation on 
    %                          this prtAction object
    %   verboseStorage       - Flag to allow or disallow verbose storage
    %   dataSetSummary       - A struct, set during training, containing
    %                          information about the training data set
    %   dataSet              - A prtDataSet, containing the training data,
    %                          only used if verboseStorage is true
    %   userData             - A struct containing user-specified data
    %
    %   All prtAction objects have the following methods:
    %
    %   train             - Train the prtAction object using a prtDataSet
    %   run               - Evaluate the prtAction object on a prtDataSet
    %   runOnTrainingData - Evaluate the prtAction object on a prtDataSet
    %                       during training prior to training of other
    %                       prtActions within a prtAlgorithm
    %   crossValidate     - Cross-validate the prtAction object using a 
    %                       labeled prtDataSet and cross-validation keys
    %   kfolds            - K-folds cross-validate the prtAction object
	%                       using a labeled prtDataSet
    %   optimize          - Optimize the prtAction for a specified
    %                       parameter
    % See Also: prtAction/train, prtAction/run, prtAction/crossValidate,
    % prtAction/kfolds, prtClass, prtRegress, prtFeatSel, prtPreProc,
    % prtDataSetBase

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


    properties (Abstract, SetAccess = private)
        % Descriptive name of prtAction object.
        name
        
        % Shortened name for the prtAction object.
        nameAbbreviation 
    end
    
    properties (Abstract, SetAccess = protected)
        % Specifies if the prtAction requires a labeled dataSet
        isSupervised
        
        % Indicates whether or not cross-validation is a valid operation
        isCrossValidateValid
    end
    
    properties (Hidden = true)
		% A tag that can be used to reference a specific action within a
		% prtAlgorithm
        tag = ''; 
    end
    
    properties (Hidden = true, SetAccess=protected, GetAccess=protected)
        classTrain = 'prtDataSetBase';
        classRun = 'prtDataSetBase';
        classRunRetained = false;
        
        verboseStorageInternal = prtAction.getVerboseStorage();
        showProgressBarInternal = prtAction.getShowProgressBar();
	end
    
    properties (Dependent)
        % Specifies whether or not to store the training prtDataset.
        % If true the training prtDataSet is stored internally prtAction.dataSet.
        verboseStorage
        showProgressBar
    end
    
    properties (SetAccess = protected)
        % Indicates if prtAction object has been trained.
        isTrained = false;
        %   Set automatically in prtAction.train().
        
        % Structure that summarizes prtDataSet.
        dataSetSummary = [];
        %   Produced by prtDataSet.summarize() and stored in
        %   prtAction.train(). Used to characterize the dataset for
        %   plotting when prtAction.verboseStorage == false
        
        %  The training prtDataSet, only stored if verboseStorage is true. 
        dataSet = []; 
         %   Only stored if prtAction.verboseStorage == true. Otherwise it
        %   is empty.
        
    end
    
    properties
        % User specified data
        userData = struct;
        %   Some prtActions store additional information from
        %   prtAction.run() as a structure in prtAction.userData()
    end
    
    methods (Abstract, Access = protected, Hidden = true)
        % prtAction.trainAction() - Primary method for training a prtAction
        %   self = prtAction.trainAction(self,DataSet)
        self = trainAction(self, ds)
        
        % prtAction.runAction() - Primary method for evaluating a prtAction
        %   ds = runAction(self, ds)
        ds = runAction(self, ds)
    end
    
    methods (Access = protected, Hidden = true)
        function xOut = runActionFast(self, xIn, ds) %#ok<STOUT,INUSD>
            error('prt:prtAction:runActionFast','The prtAction (%s) does not have a runActionFast() method. Therefore runFast() cannot be used.',class(self));
        end
    end
    
    methods (Hidden)
        function self = plus(in1,in2)
            if isa(in2,'prtAlgorithm')
                self = in2 - in1; % Use prtAlgorithm (use MINUS to flip left/right)
            elseif isa(in2,'prtAction') && (isa(in2,'prtAction') || all(cellfun(@(x)isa(x,'prtAction'),in2)))
                self = prtAlgorithm(in1) + prtAlgorithm(in2);
            else
                error('prt:prtAction:plus','prtAction.plus is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        
        function self = mldivide(in1,in2)
            if isa(in2,'prtAlgorithm')
                self = in2 / in1; % Use prtAlgorithm(use MLDIVIDE to flip left/right)
            elseif isa(in2,'prtAction')
                self = prtAlgorithm(in1) \ prtAlgorithm(in2);
            else
                error('prt:prtAction:mldivide','prtAction.mldivide is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        function self = mrdivide(in1,in2)
            if isa(in2,'prtAlgorithm')
                self = in2 \ in1; % Use prtAlgorithm(use MLDIVIDE to flip left/right)
            elseif isa(in2,'prtAction')
                self = prtAlgorithm(in1) / prtAlgorithm(in2);
            else
                error('prt:prtAction:mrdivide','prtAction.mrdivide is only defined for second inputs of type prtAlgorithm or prtAction, but the second input is a %s',class(in2));
            end
        end
        
        function dsOut = runOnTrainingData(self, dsIn)
            % RUNONTRAININGDATA  Run a prtAction object on a prtDataSet
            % object during training of a prtAlgorithm
            %
            %   OUTPUT = OBJ.run(ds) runs the prtAction object using
            %   the prtDataSet ds. OUTPUT will be a prtDataSet object.
			
            dsOut = preRunProcessing(self, dsIn);
            dsOut = runActionOnTrainingData(self, dsOut);
            dsOut = postRunProcessing(self, dsIn, dsOut);
        end
    end
    methods
        function self = train(self, ds)
            % TRAIN  Train a prtAction object using training a prtDataSet object.
            %
            %   self = Obj.train(ds) trains the prtAction object using
            %   the prtDataSet ds.
            
            if ~isscalar(self)
                error('prt:prtAction:NonScalarAction','train method expects scalar prtAction objects, prtAction provided was of size %s',mat2str(size(self)));
            end

            inputClassType = class(ds);
            if ~isempty(self.classTrain) && ~prtUtilDataSetClassCheck(inputClassType,self.classTrain)
                error('prt:prtAction:incompatible','%s.train() requires datasets of type %s but the input is of type %s, which is not a subclass of %s', class(self), self.classTrain, inputClassType, self.classTrain);
            end
            
            if self.isSupervised && ~ds.isLabeled
                error('prt:prtAction:noLabels','%s is a supervised action and therefore requires that the training dataset is labeled',class(self));
            end 
            
            % Default preTrainProcessing() stuff
            self.dataSetSummary = summarize(ds);
            
            %preTrainProcessing should make sure self has the right
            %verboseStorage
            self = preTrainProcessing(self,ds);
            
            if self.verboseStorage
                self.dataSet = ds;
            end
            
            self = trainAction(self, ds);
            self.isTrained = true;
            self = postTrainProcessing(self,ds);
        end
        
        function [dsOut, extraOutput] = run(self, dsIn)         
            % RUN  Run a prtAction object on a prtDataSet object.
            %
            %   dsOut = OBJ.run(ds) runs the prtAction object using
            %   the prtDataSet DataSet. OUTPUT will be a prtDataSet object.
            
            if ~self.isTrained
                error('prtAction:run:ActionNotTrained','Attempt to run a prtAction of type %s that was not trained',class(self));
            end
                
            inputClassName = class(dsIn);
            
            if ~isempty(self.classRun) && ~prtUtilDataSetClassCheck(inputClassName,self.classRun)
                error('prt:prtAction:incompatible','%s.run() requires datasets of type %s but the input is of type %s, which is not a subclass of %s.',class(self), self.classRun, inputClassName, self.classRun);
            end
            
            if isempty(dsIn)
                dsOut = dsIn;
                return
            end
            
            dsOut = preRunProcessing(self, dsIn);
            switch nargout
                case {0,1}
                   dsOut = runAction(self, dsOut);
                case 2 
                    [dsOut, extraOutput] = runAction(self, dsOut);
            end
            dsOut = postRunProcessing(self, dsIn, dsOut);
            
            outputClassName = class(dsOut);
            
            if self.classRunRetained && ~isequal(outputClassName,inputClassName)
                error('prt:prtAction:incompatible','%s specifies that it retains the class of input datasets however, the class of the output dataset is %s and the class of the input dataset is %s. This may indicate an error with the runAction() method of %s.', class(self), self.classRun, inputClassName, class(self));
            end
        end
        
        function self = set.classRun(self,val)
            assert(ischar(val),'prt:prtAction:classRun','classRun must be a string.');
            self.classRun = val;
        end
        function self = set.classTrain(self,val)
            assert(ischar(val),'prt:prtAction:classTrain','classTrain must be a string.');
            self.classTrain = val;
        end
        
        function self = set.classRunRetained(self,val)
            assert(prtUtilIsLogicalScalar(val),'prt:prtAction:classRunRetained','classRunRetained must be a scalar logical.');
            self.classRunRetained = val;
        end        
        
        function self = set.verboseStorage(self,val)
            self = self.setVerboseStorage(val);
			self.dataSet = [];
        end
        
        function self = set.showProgressBar(self,val)
            self = self.setShowProgressBar(val);
        end
        
        function val = get.verboseStorage(self)
            val = self.verboseStorageInternal;
        end
        
        function val = get.showProgressBar(self)
            val = self.showProgressBarInternal;
        end
        
        function [dsOut, trainedActions] = crossValidate(self, dsIn, validationKeys)
            % CROSSVALIDATE  Cross validate prtAction using prtDataSet and cross validation keys.
            %
            %  OUTPUTDATASET = OBJ.crossValidate(DATASET, KEYS) cross-
            %  validates the prtAction object OBJ using the prtDataSet
            %  DATASET and the KEYS. DATASET must be a labeled prtDataSet.
            %  KEYS must be a vector of integers with the same number of
            %  elements as DATASET has observations.
            %
            %  The KEYS are are used to parition the input DATASET into
            %  test and training data sets. For each unique key, a test set
            %  will be created out of the corresponding observations of the
            %  prtDataSet. The remaining observations will be used as
            %  training data.
            %
            %  [OUTPUTDATASET, TRAINEDACTIONS] = OBJ.crossValidate(DATASET,
            %  KEYS) outputs the trained prtAction objects TRAINEDACTIONS.
            %  TRAINEDACTIONS will have a length equal to the number of
            %  unique KEYS.
            
            
            % Check for isCrossValidateValid removed - 2012-11-08
            % This now handled by allowing the dataset to check the fold
            % results.
            

            if ~isvector(validationKeys) || (numel(validationKeys) ~= dsIn.nObservations)
                error('prt:prtAction:crossValidate','validationKeys must be a vector with a length equal to the number of observations in the data set');
            end
            
			validationKeys = validationKeys(:);
			
            uKeys = unique(validationKeys);
            
            actuallyShowProgressBar = self.showProgressBar && (length(uKeys) > 1);
            if actuallyShowProgressBar
                waitBarself = prtUtilProgressBar(0,sprintf('Crossvalidating - %s',self.name),'autoClose',true);
                cleanupObj = onCleanup(@()cleanUpHandles(waitBarself));

				%cleanupself = onCleanup(@()close(waitBarself));
				% The above would close the waitBar upon completion but
				% it doesn't play nice when there are many bars in the
				% same window
            end            
            
			testingIndiciesCell = cell(length(uKeys),1);
			outputDataSetCell = cell(length(uKeys),1);
			for uInd = 1:length(uKeys);
				
				if actuallyShowProgressBar
					waitBarself.update((uInd-1)/length(uKeys));
				end
				
				% Get the testing indices
				if isa(uKeys(uInd),'cell')
					cTestLogical = strcmp(uKeys(uInd),validationKeys);
				else
					cTestLogical = uKeys(uInd) == validationKeys;
				end
				
				% Store the indicies for resorting later
				testingIndiciesCell{uInd} = find(cTestLogical);
				testDs = dsIn.retainObservations(cTestLogical);
				
				% Get the training dataset
				if length(uKeys) == 1  %1-fold, incestuous train and test
					trainDs = testDs;
				else
					trainDs = dsIn.removeObservations(cTestLogical);
				end
				
				% Train the action using the training dataset
				trainedAction = self.train(trainDs);
				
				% Run the trained action on the test dataset
				outputDataSetCell{uInd} = trainedAction.run(testDs);
                
				% Ask the input dataset to assess the quality of the fold
				% and the results.
				% This check allows prtDataSetClass to check to make sure
				% that all classes are represented in each fold.
				outputDataSetCell{uInd} = crossValidateCheckFoldResults(dsIn, trainDs, testDs, outputDataSetCell{uInd});
				
				% Only do this if the output is requested; otherwise this
				% cell of actions can get large if verboseStorage is true
				if nargout >= 2
					if uInd == 1
						% First iteration pre-allocate
						trainedActions = repmat(trainedAction,length(uKeys),1);
					else
						trainedActions(uInd) = trainedAction;
					end
				end
            end
            
			
			dsOut = crossValidateCombineFoldResults(outputDataSetCell{1}, outputDataSetCell, testingIndiciesCell);
			
			dsOut = dsOut.acquireNonDataAttributesFrom(dsIn);
            
            function cleanUpHandles(wbHandle)
                wbHandle.update(1);
            end
		end
        
		function [dsOut, trainedActions] = crossValidate2dKeys(self, dsIn, validationKeys)
            % CROSSVALIDATE  Cross validate prtAction using prtDataSet and cross validation keys.
            %
            %  OUTPUTDATASET = OBJ.crossValidate(DATASET, KEYS) cross-
            %  validates the prtAction object OBJ using the prtDataSet
            %  DATASET and the KEYS. DATASET must be a labeled prtDataSet.
			%
            %  KEYS may be a vector of integers or a cell array of strings
			%  with the same number of elements as DATASET has observations
			%  or it may be an N-by-D array of integers where N is the
			%  number of observations.
            %
            %  The KEYS are are used to partition the input DATASET into
            %  test and training data sets. For each unique key (or set of 
			%  D keys), a test set will be created out of the corresponding
			%  observations of the prtDataSet. The observations sharing
			%  none of those keys will be used as training data.
            %
            %  [OUTPUTDATASET, TRAINEDACTIONS] = OBJ.crossValidate(DATASET,
            %  KEYS) outputs the trained prtAction objects TRAINEDACTIONS.
            %  TRAINEDACTIONS will have a length equal to the number of
            %  unique KEYS.
            
            
            % Check for isCrossValidateValid removed - 2012-11-08
            % This now handled by allowing the dataset to check the fold
            % results.
            

            if (size(validationKeys,1) ~= dsIn.nObservations) && (~isvector(validationKeys) || (numel(validationKeys) ~= dsIn.nObservations))
                error('prt:prtAction:crossValidate','validationKeys must have length equal to the number of observations in the data set');
			end
            
			if isvector(validationKeys)
				validationKeys = validationKeys(:);
			end
			
            uKeys = unique(validationKeys,'rows');
            
            actuallyShowProgressBar = self.showProgressBar && (length(uKeys) > 1);
            if actuallyShowProgressBar
                waitBarself = prtUtilProgressBar(0,sprintf('Crossvalidating - %s',self.name),'autoClose',true);
                cleanupObj = onCleanup(@()cleanUpHandles(waitBarself));

				%cleanupself = onCleanup(@()close(waitBarself));
				% The above would close the waitBar upon completion but
				% it doesn't play nice when there are many bars in the
				% same window
            end            
            
			testingIndiciesCell = cell(length(uKeys),1);
			outputDataSetCell = cell(length(uKeys),1);
			for uInd = 1:size(uKeys,1);
				
				if actuallyShowProgressBar
					waitBarself.update((uInd-1)/length(uKeys));
				end
				
				% Get the testing indices
				if isa(uKeys(uInd),'cell')
					cTestLogical = strcmp(uKeys(uInd),validationKeys);
					cTrainLogical = ~cTestLogical;
				else
					cmp = bsxfun(@eq,uKeys(uInd,:),validationKeys);
					cTestLogical = all(cmp,2);
					cTrainLogical = ~any(cmp,2);
				end
				
				% Store the indicies for resorting later
				testingIndiciesCell{uInd} = find(cTestLogical);
				testDs = dsIn.retainObservations(cTestLogical);
				
				% Get the training dataset
				if length(uKeys) == 1  %1-fold, incestuous train and test
					trainDs = testDs;
				else
					trainDs = dsIn.retainObservations(cTrainLogical);
				end
				
				% Train the action using the training dataset
				trainedAction = self.train(trainDs);
				
				% Run the trained action on the test dataset
				outputDataSetCell{uInd} = trainedAction.run(testDs);
                
				% Ask the input dataset to assess the quality of the fold
				% and the results.
				% This check allows prtDataSetClass to check to make sure
				% that all classes are represented in each fold.
				outputDataSetCell{uInd} = crossValidateCheckFoldResults(dsIn, trainDs, testDs, outputDataSetCell{uInd});
				
				% Only do this if the output is requested; otherwise this
				% cell of actions can get large if verboseStorage is true
				if nargout >= 2
					if uInd == 1
						% First iteration pre-allocate
						trainedActions = repmat(trainedAction,length(uKeys),1);
					else
						trainedActions(uInd) = trainedAction;
					end
				end
            end
            
			
			dsOut = crossValidateCombineFoldResults(outputDataSetCell{1}, outputDataSetCell, testingIndiciesCell);
			
			dsOut = dsOut.acquireNonDataAttributesFrom(dsIn);
            
            function cleanUpHandles(wbHandle)
                wbHandle.update(1);
            end
        end
		
        function varargout = kfolds(self, ds , k)
            % KFOLDS  Perform K-folds cross-validation of prtAction
            % 
            %    OUTPUTDATASET = self.KFOLDS(DATASET, K) performs K-folds
            %    cross-validation of the prtAction object OBJ using the
            %    prtDataSet DATASET. DATASET must be a labeled prtDataSet,
            %    and K must be a scalar integer, representing the number
            %    of folds. KFOLDS Generates cross-validation keys by
            %    partitioning the dataSet into K groups such that the
			%    number of samples of each unique target type is held
			%    approximately constant.
            %
            %    [OUTPUTDATASET, TRAINEDACTIONS, CROSSVALKEYS] =
            %    self.KFOLDS(DATASET, K)  outputs the trained prtAction
            %    objects TRAINEDACTIONS, and the generated cross-validation
            %    keys CROSSVALKEYS.
            %
            %    To manually set which observations are in which folds, see
            %    crossValidate.
            
            
            assert(isa(ds,'prtDataSetBase'),'First input must by a prtDataSet.');
            
            if nargin == 2 || isempty(k)
                k = ds.nObservations;
            end
            
            assert(prtUtilIsPositiveScalarInteger(k),'prt:prtAction:kfolds','k must be a positive scalar integer');
            
            nObs = ds.nObservations;
            if k > nObs;
                warning('prt:prtAction:kfolds:nFolds','Number of folds (%d) is greater than number of data points (%d); assuming Leave One Out training and testing',k,nObs);
                k = nObs;
            elseif k < 1
                warning('prt:prtAction:kfolds:nFolds','Number of folds (%d) is less than 1 assuming FULL training and testing',k);
                k = 1;
            end
            
            keys = ds.getKFoldKeys(k);
            
            outputs = cell(1,min(max(nargout,1),2));
            [outputs{:}] = self.crossValidate(ds,keys);
            
            varargout = outputs(:);
            if nargout > 2
                varargout = [varargout; {keys}];
            end
        end
        
        function self = set(self,varargin)
            % set - set the object properties
            %   
            % OBJ = OBJ.set(PARAM, VALUE) sets the parameter PARAM of OBJ
            % to the value VALUE. PARAM must be a string indicating the
            % parameter to be set.
            %
            % OBJ = OBJ.set(PARAM1, VALUE1, PARAM2, VALUE2....) sets all
            % the desired parameters to the specified values.
            
            % Actionself = get(ActionObj,paramNameStr,paramValue);
            % ActionObj = get(ActionObj,paramNameStr1,paramValue1, paramNameStr2, paramNameValue2, ...); 
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function out = get(self,varargin)
            % get - get the object properties
            % 
            % val = obj.get(PARAM) returns the value of the parameter
            % specified by the string PARAM.
            %
            % vals = obj.get(PARAM1, PARAM2....) returns a structure
            % containing the values of all the parameters specified by the
            % PARAM strings
            
            
            % paramValue = get(ActionObj,paramNameStr);
            % paramStruct = get(ActionObj,paramNameStr1,paramNameStr2,...);
            
            nameStrs = varargin;
            
            assert(iscellstr(nameStrs),'additional input arguments must be property name strings');
            
            % No additional inputs, assume all
            if isempty(nameStrs)
                nameStrs = properties(self);
            end
            
            % Only one property requested
            % Return value
            if numel(nameStrs)==1
                out = self.(nameStrs{1});
                return
            end

            % Several properties requested
            % Return structure of values
            out = struct;
            for iProp = 1:length(nameStrs)
                out.(nameStrs{iProp}) = self.(nameStrs{iProp});
            end
        end
        
    end
    
    methods (Access=protected, Hidden= true)
        function self = preTrainProcessing(self, ds) %#ok<INUSD>
            % preTrainProcessing - Processing done prior to trainAction()
            %   Called by train(). Can be overloaded by prtActions to
            %   store specific information about the DataSet or Classifier
            %   prior to training.
            %   
            %   ActionObj = preTrainProcessing(ActionObj,DataSet)
        end
        
        function self = postTrainProcessing(self, ds) %#ok<INUSD>
            % postTrainProcessing - Processing done after trainAction()
            %   Called by train(). Can be overloaded by prtActions to
            %   store specific information about the DataSet or Classifier
            %   after training.
            %   
            %   ActionObj = postTrainProcessing(ActionObj,DataSet)
        end
        
        function ds = preRunProcessing(self, ds)  %#ok<INUSL>
            % preRunProcessing - Processing done before runAction()
            %   Called by run(). Can be overloaded by prtActions to
            %   store specific information about the DataSet or Classifier
            %   prior to runAction.
            %   
            %   DataSet = preRunProcessing(ActionObj, DataSet)
        end        
        
        function dsOut = postRunProcessing(self, dsIn, dsOut)
            % postRunProcessing - Processing done after runAction()
            %   Called by run(). Can be overloaded by prtActions to alter
            %   the results of run() using parameters of the prtAction.
            %   
            %   DataSetOut = postRunProcessing(ActionObj, DataSetIn, DataSetOut)
            
            if dsIn.nObservations > 0
                if self.isCrossValidateValid
                    dsOut = dsOut.acquireNonDataAttributesFrom(dsIn);
                end
                % Allow actions to modify featureNames
                dsOut = dsOut.modifyNonDataAttributesFrom(self);
            end
        end
        
        function xIn = preRunProcessingFast(ActionObj, xIn, ds) %#ok<INUSL,INUSD>
            % preRunProcessingFast - Processing done before runAction()
            %   Called by runFast(). Can be overloaded by prtActions to
            %   store specific information about the xIn or Classifier
            %   prior to runAction.
            %   
            %   xOut = preRunProcessingFast(ActionObj, xIn, ds)
        end
        
        function xOut = postRunProcessingFast(self, xIn, xOut, dsIn) %#ok<INUSL,MANU,INUSD>
            % postRunProcessingFast - Processing done after runAction()
            %   Called by runFast(). Can be overloaded by prtActions to
            %   alter the results of run() using parameters of the
			%   prtAction.
            %   
            %   xOut = postRunProcessingFast(ActionObj, xIn, xOut, dsIn)
        end
    end
    methods (Access = protected, Hidden)
        function dsOut = runActionOnTrainingData(self, dsIn)
            % RUNACTIONONTRAININGDATA Run a prtAction object on a prtDataSet object
            %   This method differs from RUN() in that it is called after
            %   train() within prtAlgorithm prior to training of subsequent
            %   actions. By default this method is the same as RUN() but it
            %   can be overloaded by prtActions to enable things such as 
            %   outlier removal.
            %
            %    dsOut = runOnTrainingData(self dsIn);
            
            dsOut = runAction(self, dsIn);
        end
    end
    methods (Hidden)
        function self = setIsTrained(self,val)
            if nargin < 2 || isempty(val)
                error('A value must be specified');
            end
            assert(prtUtilIsLogicalScalar(val),'isTrained must be a logical scalar');
            
            self.isTrained = true;
        end
        function self = setDataSet(self, val)
            self.dataSet = val;
        end
        function self = setDataSetSummary(self, summary)
            self.dataSetSummary = summary;
        end
    end
              
    
    methods (Hidden = false)
        function [optimizedAction, performance] = optimize(self, ds , objFn, parameterName, parameterValues)
            % OPTIMIZE Optimize action parameter by exhaustive function maximization.
            %
            %  OPTIMACT = OPTIMIZE(DS, EVALFN, PARAMNAME, PARAMVALS)
            %  returns an optimized prtAction object, with parameter
            %  PARAMNAME set to the optimal value. DS must be a prtDataSet
            %  object. EVALFN must be a function handle that returns a
            %  scalar value that indicates a performance metric for the
            %  prtAction object, for example a prtEval function. PARAMNAME
            %  must be a string that indicates the parameter of the
            %  prtAction that is to be optimized. PARAMVALS must be a
            %  vector of possible values of the parameter at which
            %  prtAction will be evaluated.
            %
            %  [OPTIMACT, PERF]  = OPTIMIZE(...) returns a vector of
            %  performance values that correspond to each element of
            %  PARAMVALS.
            %
            % Example:
            %
            %  ds = prtDataGenBimodal;  % Load a data set
            %  knn = prtClassKnn;       % Create a classifier
            %  kVec = 3:5:50;           % Create a vector of parameters to
            %                           % optimze over
            %
            % % Optimize over the range of k values, using the area under
            % % the receiver operating curve as the evaluation metric.
            % % Validation is performed by a k-folds cross validation with
            % % 10 folds as specified by the call to prtEvalAuc.
            %           
            % [knnOptimize, percentCorrects] = knn.optimize(ds, @(class,ds)prtEvalAuc(class,ds,10), 'k',kVec);
            % plot(kVec, percentCorrects)

            
            %   objFn = @(act,ds)prtEvalAuc(act,ds,3);
            %   [optimizedAction,performance] = optimize(self,DataSet,objFn,parameterName,parameterValues)
            
            if isnumeric(parameterValues) || islogical(parameterValues)
                parameterValues = num2cell(parameterValues);
            end
            performance = nan(length(parameterValues),1);
            
            if self.showProgressBar
                h = prtUtilProgressBar(0,sprintf('Optimizing %s.%s',class(self),parameterName),'autoClose',true);
            end
            
            for i = 1:length(performance)
                self.(parameterName) = parameterValues{i};
                performance(i) = objFn(self, ds);
                
                if self.showProgressBar
                    h.update(i/length(performance));
                end
            end
            if self.showProgressBar
                % Force close
                h.update(1);
            end
            
            [maxPerformance,maxPerformanceInd] = max(performance); %#ok<ASGLU>
            self.(parameterName) = parameterValues{maxPerformanceInd};
            optimizedAction = train(self,ds);
            
        end
    end
    methods(Hidden = true)
        function [outputObj, creationString] = gui(obj)
            % GUI Graphical method to set properties of prtAction
            %
            % [outputObj, creationString] = gui(obj)
            % 
            % outputObj - Object with specified parameters
            % creationString - code to recreate gui actions
            %
            % Not all properties are currently able to be set using gui
            %
            % Example:
            %   knn = prtClassKnn;
            %   knn.gui
            
            [outputObj, creationString] = prtUtilObjectGuiSimple(obj);
        end
    end
    
    methods (Hidden = true)
        function [out,varargout] = rt(self,in)
            % Train and then run an action on a dataset
            switch nargout
                case 1
                    out = run(train(self,in),in);
                otherwise
                    varargout = cell(1,nargout-1);
                    [out,varargout{:}] = run(train(self,in),in);
            end
        end
        
        function self = setVerboseStorage(self,val)
            assert(numel(val)==1 && (islogical(val) || (isnumeric(val) && (val==0 || val==1))),'prtAction:invalidVerboseStorage','verboseStorage must be a logical');
            self.verboseStorageInternal = logical(val);
        end
        
        function self = setVerboseFeatureNames(self,val)
            assert(numel(val)==1 && (islogical(val) || (isnumeric(val) && (val==0 || val==1))),'prtAction:invalidVerboseFeatureNames','verboseFeatureNames must be a logical');
            self.verboseFeatureNamesInternal = logical(val);
        end
        
        function self = setShowProgressBar(self,val)
            if ~prtUtilIsLogicalScalar(val);
                error('prt:prtAction','showProgressBar must be a scalar logical.');
            end
            self.showProgressBarInternal = val;
        end
        
        function varargout = export(obj,exportType,varargin)
            % export(obj,fileSpec);
            % S = export(obj,'struct');
            if nargin < 2
                error('prt:prtAction:export','exportType must be specified');
            end
                
            switch lower(exportType)
                case {'struct','structure'}
                    varargout{1} = toStructure(obj);
                    
                case {'yaml'}
                    if nargin < 3
                        error('prt:prtAction:exportYaml','fileName must be specified to export YAML');
                    end
                    file = varargin{1};
                    
                    objStruct = toStructure(obj);
                    
                    prtExternal.yaml.WriteYaml(file,objStruct);
                    
                    varargout = {};
                    
                case {'eml'}
                    if length(varargin) < 2
                        structureName = cat(2,class(obj),'Structure');
                    else
                        structureName = varargin{2};
                    end
                    if length(varargin) < 1
                        file = sprintf('%sCreate',structureName);
                    else
                        file = varargin{1};
                    end
                    
                    [filePath, file, fileExt] = fileparts(file); %#ok<NASGU>
                    
                    if ~isvarname(file)
                        error('prt:prtAction:export','When using EML export, file must be a string that is a valid MATLAB function name (optionally it can also contain a path.)');
                    end
                    
                    fileWithMExt = cat(2,file,'.m');
                    
                    exportStruct = obj.toStructure();

                    exportString = prtUtilStructToStr(exportStruct,structureName);
                    
                    % Add a function declaration name to the beginning
                    exportString = cat(1, {sprintf('function [%s] = %s()',structureName,file)}, {''}, exportString);
                    
                    fid = fopen(fullfile(filePath,fileWithMExt),'w');
                    fprintf(fid,'%s\n',exportString{:});
                    fclose(fid);
                    
                case 'simpletext'

                    varargout{1} = obj.exportSimpleText;
                    
                    if nargin == 3
                        file = varargin{1};
                        fid = fopen(file,'w');
                        fprintf(fid,'%s\n',varargout{1});
                        fclose(fid);
                    end
    
                otherwise
                    error('prt:prtAction:export','Invalid file formal specified');
            end
        end
        
        function S = toStructure(self)
            % toStructure(self)
            % This default prtAction method adds all properties defined in
            % the class of self into the structure, that are:
            %   GetAccess: public
            %   Hidden: false
            % other prtActions (that are properties, contained in cells,
            %   or fields of structures) are also converted to structures.
            
            MetaInfo = meta.class.fromName(class(self));
            
            propNames = {};
            for iProperty = 1:length(MetaInfo.Properties)
                if isequal(MetaInfo.Properties{iProperty}.DefiningClass,MetaInfo) && strcmpi(MetaInfo.Properties{iProperty}.GetAccess,'public') && ~MetaInfo.Properties{iProperty}.Hidden
                    propNames{end+1} = MetaInfo.Properties{iProperty}.Name; %#ok<AGROW>
                end
            end
            
            S.class = 'prtAction';
            S.prtActionType = class(self);
            S.isSupervised = self.isSupervised;
            S.dataSetSummary = self.dataSetSummary;
            for iProp = 1:length(propNames)
                cProp = self.(propNames{iProp});
                if ischar(cProp) || isnumeric(cProp) || isa(cProp,'function_handle') || islogical(cProp)
                    cVal = cProp;
                else
                    for icProp = 1:length(cProp) % Allow for arrays of objects
                        cOut = prtUtilFindPrtActionsAndConvertToStructures(cProp(icProp));
                        
                        if icProp == 1
                            cVal = repmat(cOut,size(cProp));
                        else
                            cVal(icProp) = cOut;
                        end
                    end
                end
                
                S.(propNames{iProp}) = cVal;
            end
            S.userData = self.userData;
        end
        
        function xOut = runFast(self, xIn, ds)         
            % RUNFAST  Run a prtAction object on a matrix.
            %   The specific action must have overloaded the runActionFast
            %   method.
            
            if ~self.isTrained
                error('prtAction:runFast:ActionNotTrained','Attempt to run a prtAction of type %s that was not trained',class(self));
            end
                
            if isempty(xIn)
                xOut = xIn;
                return
            end
            
            if nargin > 2
                xIn = preRunProcessingFast(self, xIn, ds);
                xOut = runActionFast(self, xIn, ds);
                xOut = postRunProcessingFast(self, xIn, xOut, ds);
            else
                xIn = preRunProcessingFast(self, xIn);
                xOut = runActionFast(self, xIn);
                xOut = postRunProcessingFast(self, xIn, xOut);
            end
        end
    end
    
    methods (Hidden, Static)
        function val = getVerboseStorage()
            val = true;
%             val = prtOptionsGet('prtOptionsComputation','verboseStorage');
        end
        function val = getShowProgressBar()
            val = true;
%             val = prtOptionsGet('prtOptionsComputation','showProgressBar');
        end        
	end
	
	methods (Hidden = true)
        function str = exportSimpleText(self) %#ok<MANU>
            error('exportSimpleText must be overloaded in sub-classes');
        end
        function str = textSummary(self) %#ok<MANU>
            % str = textSummary(self)
            %   Give a short textual summary of the object in the output
            %   str.  The summary shows what a call to "display" would call
            %   using only public fields, and ignoring a lot of
            %   general-purpose fields.  We can specify this in more detail
            %   if people like it.  Also, different actions can sub-class this to
            %   do whatever they want.
            %
            %   Works on actions:
            %       pca = train(prtPreProcPca('nComponents',2),prtDataGenBimodal);
            %       textSummary(pca)
            %
            %   And algorithms:
            %       algo = train(prtPreProcPls('nComponents',2) + prtClassLibSvm,prtDataGenBimodal);
            %       algo.textSummary
            
            warning off; %#ok<WNOFF>
            s = struct(self);
            warning on; %#ok<WNON>
            rmFieldNames = {'nameAbbreviation','isNativeMary','plotBasis','plotProjections','twoClassParadigm','internalDecider','isSupervised','isCrossValidateValid','verboseStorage','showProgressBar','isTrained','dataSetSummary','dataSet','userData'};
            publicFieldNames = properties(self);
            totalFieldNames = fieldnames(s);
            
            rmFieldNames = union(rmFieldNames,setdiff(totalFieldNames,publicFieldNames));
            rmFieldNames = intersect(rmFieldNames,totalFieldNames);
            s = rmfield(s,rmFieldNames); %#ok<NASGU>
            
            str = sprintf('%s: \n',class(self));
            str2 = evalc('disp(s)');
            str2 = deblank(str2);
            str2 = sprintf('%s\n\n',str2);
            str = sprintf('%s%s',str,str2);
        end
        
		function fun = getFeatureNameModificationFunction(self) %#ok<MANU>
			fun = []; % Default we output empty which means don't change anything...
			
			% The alternative is to output a function handle of the form
			% @(nameIn, index)modificationFunction(nameIn); 
			
			% This is overloaded by prtClass to set the names to designate
			% that they are now algorithm confidences
			
			% Putting this in prtAction is a little strange because some
			% actions can operate only on datasets that do not technically
			% have features. In these cases this method should just be
			% ignored. The alternative is to store this in a class of
			% actions that opperate only on prtDataSetStandards. It has
			% been decided that this would over complicate the class
			% hierarchy since this is the only exception at this point and
			% it is easily ignored.
		end
	end
	
end
