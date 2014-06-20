classdef prtClassMap < prtClass
 %prtClassMap  Maximum a Posteriori classifier
 % 
 %    CLASSIFIER = prtClassMap returns a Maximum a Posteriori classifier
 %
 %    CLASSIFIER = prtClassMap(PROPERTY1, VALUE1, ...) constructs a
 %    prtClassMAP object CLASSIFIER with properties as specified by
 %    PROPERTY/VALUE pairs.
 %
 %    A prtClassMap object inherits all properties from the abstract class
 %    prtClass. In addition is has the following property:
 %
 %    rvs    - A prtRv object. This property describes the random variable 
 %             model used for Maximum a Posteriori classification.
 %
 %    A prtClassMap object inherits inherits the TRAIN, RUN, CROSSVALIDATE
 %    and KFOLDS methods from prtClass.
 %
 %    Example:
 %
 %    Test` = prtDataGenUnimodal;       % Create some test and
 %    TrainingDataSet = prtDataGenUnimodal;   % training data
 %    classifier = prtClassMap;               % Create a classifier
 %    classifier = classifier.train(TrainingDataSet);    % Train
 %    classified = run(classifier, TestDataSet);         % Test
 %
 %    subplot(2,1,1); classifier.plot;  % Plot results
 %    subplot(2,1,2); prtScoreRoc(classified,TestDataSet);
 %    set(get(gca,'Children'), 'LineWidth',3) 
 %
 %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
 %    prtClassMap, prtClassFld, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
 %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClassSvm,
 %    prtClassTreeBaggingCap, prtClassKmsd, prtClassKnn                   

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
        % Required by prtAction
        name = 'Maximum a Posteriori'   % Maximum a Posteriori
        nameAbbreviation = 'MAP'        % MAP
        isNativeMary = true;            % True
    end
    
    properties
        rvs = prtRvMvn; % Random variable object containing mean and variance
    end
    properties (Hidden)
        runLogLikelihoods = false
    end
    
    methods
        % Constructor
        function self = prtClassMap(varargin)
            
            self.classTrain = 'prtDataInterfaceCategoricalTargets';
            self.classRun = 'prtDataSetBase';
            self.classRunRetained = false;
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        % Set function
        function self = set.rvs(self,val)
            if ~(isa(val, 'prtRv') || isa(val, 'prtBrv')) 
                error('prtClassMAP:rvs','Rvs parameter must be of class prtRv');
            else
                self.rvs = val;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,ds)
            
            % Repmat the rv objects to get one for each class
            % The pattern of supplied RVs repeats, if 2 rvs are suplied for
            % a three class problem, the third class gets the same as class
            % 1, if there were a fourth class if would be the same as class
            % 2.
            self.rvs = repmat(self.rvs(:), (ds.nClasses - length(self.rvs)+1),1);
            self.rvs = self.rvs(1:ds.nClasses);
            
            % Get the ML estimates of the RV parameters for each class
            for iY = 1:ds.nClasses
                self.rvs(iY) = train(self.rvs(iY), ds.retainClassesByInd(iY));
            end
        end
        
        function ds = runAction(self,ds)
            
            % We call run for each RV
            % Typically this is the loglikelihood, but it might not be.
            logLikelihoods = zeros(ds.nObservations, length(self.rvs));
            for iY = 1:length(self.rvs)
                logLikelihoods(:,iY) = getObservations(run(self.rvs(iY), ds));
            end
            
            if ~self.runLogLikelihoods
                % If we don't want loglikelihoods transform them to
                % probabilities
                logLikelihoods = exp(bsxfun(@minus, logLikelihoods, prtUtilSumExp(logLikelihoods.').'));
            end
            ds.X = logLikelihoods;
        end
    
        function xOut = runActionFast(self,xIn,ds) %#ok<INUSD>
            
            logLikelihoods = zeros(size(xIn,1),length(self.rvs));
            for iY = 1:length(self.rvs)
                logLikelihoods(:,iY) = runFast(self.rvs(iY), xIn);
            end
            
            if ~self.runLogLikelihoods
                % If we don't want loglikelihoods transform them to
                % probabilities
                xOut = exp(bsxfun(@minus, logLikelihoods, prtUtilSumExp(logLikelihoods.').'));
            else
                xOut = logLikelihoods;
            end
        end
    end
    
end
