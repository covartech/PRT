classdef prtClassBagging < prtClass
    % prtClassBagging  Bagging (Bootstrap Aggregating) classifier
    %
    %    CLASSIFIER = prtClassBagging returns a bagging classifier
    %
    %    CLASSIFIER = prtClassBagging(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassBagging object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassBagging object inherits all properties from the abstract
    %    class prtClass. In addition is has the following properties:
    %
    %    baseClassifier  - The base classifier to be used 
    %    nBags           - The number of bags to aggregate over
    %    nSamplesPerBag  - The number of bootstrap samples to use per bag.
    %           When nSamplesPerBag is an empty matrix (the default),
    %           the number of bootstrap samples is set to the number of
    %           observations in the training data set.
    %    bootstrapByClass - A logical describing whether to enforce an
    %           equal number of bootstrap samples from each class in the
    %           training data set. If bootstrapByClass is true,
    %           floor(nSamplesPerBag/nClasses) samples per class are used
    %           when training each classifier.  bootstrapByClass defaults
    %           to false.
    % 
    %    Bagging classifiers are meta-classifiers that attempt to develop
    %    more robust decision boundaries by aggregating outputs over
    %    multiple bootstrapped samples of the original data.  For more
    %    information on bagging classifiers, see:
    %
    %    http://en.wikipedia.org/wiki/Bootstrap_aggregating
    %
    %    A prtClassBagging  object inherits the TRAIN, RUN, 
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits 
    %    the PLOT method from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUnimodal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassBagging;           % Create a classifier
    %     classifier.baseClassifier = prtClassMap; % Set the classifier to
    %                                              % a prtClassMap
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     subplot(2,1,1);
    %     classifier.plot;
    %     subplot(2,1,2);
    %     [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %     h = plot(pf,pd,'linewidth',3);
    %     title('ROC'); xlabel('Pf'); ylabel('Pd');
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
        name = 'Bagging Classifier'   %  Bagging Classifier
        nameAbbreviation = 'Bagging'  %  Bagging
        isNativeMary = false;         % False
    end
    
    properties
        nBags = 100;                   % The number of bags
        nSamplesPerBag = [];           % The number of bootstrap samples to use in each bag
        bootstrapByClass = false;      % Whether to force an equal number of bootstrap samples per class
    end
    properties (SetAccess=protected, Hidden = true)
        Classifiers
        internalBaseClassifier = prtClassFld;
    end
    properties (Dependent)
        baseClassifier                 % The classifier to be bagged
    end
    
    methods
        
        function Obj = prtClassBagging(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nBags(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val)
               error('prt:prtClassBagging:nBags','nBags must be a positive scalar integer'); 
            end
            Obj.nBags = val;
        end
        
        function Obj = set.nSamplesPerBag(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val) && ~isempty(val)
               error('prt:prtClassBagging:nSamplesPerBag','nSamplesPerBag must be empty, or a positive scalar integer'); 
            end
            Obj.nSamplesPerBag = val;
        end
        
        
        function Obj = set.bootstrapByClass(Obj,val)
            if ~prtUtilIsLogicalScalar(val)
               error('prt:prtClassBagging:bootstrapByClass','bootstrapByClass must be a logical scalar'); 
            end
            Obj.bootstrapByClass = val;
        end
        
        function Obj = set.baseClassifier(Obj,classifier)
            if ~isa(classifier,'prtClass')
                error('prt:prtClassBagging','baseClassifier must be a subclass of prtClass, but classifier provided was a %s',class(classifier));
            end
            Obj.isNativeMary = classifier.isNativeMary;
            Obj.internalBaseClassifier = classifier;
        end
        
        function value = get.baseClassifier(Obj)
            value = Obj.internalBaseClassifier;
        end
        
    end
    methods (Hidden = true)
        
        function self = setClassifier(self,newClassifierArray)
           self.Classifiers = newClassifierArray;
        end
        
        function Obj = setVerboseStorage(Obj,val)
            assert(numel(val)==1 && (islogical(val) || (isnumeric(val) && (val==0 || val==1))),'prtAction:invalidVerboseStorage','verboseStorage must be a logical');
            Obj.verboseStorageInternal = logical(val);
            
            Obj.baseClassifier.verboseStorage = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)

            Obj.nameAbbreviation = sprintf('Bagging_{%s}',Obj.baseClassifier.nameAbbreviation);
            %Infer the number of boostrap samples; if nSamplesPerBag is 
            %empty, default to nObservations 
            nBootstrapSamples = Obj.nSamplesPerBag;
            if isempty(nBootstrapSamples)
                nBootstrapSamples = DataSet.nObservations;
            end
            for i = 1:Obj.nBags
                %Figure out which bootstrap function to call, and how many
                %samples we need
                if Obj.bootstrapByClass
                    %To make approximately nBootstrapSamples total, use
                    %nBootstrapSamples/DataSet.nClasses per class
                    bootstrapData = DataSet.bootstrapByClass(floor(nBootstrapSamples/DataSet.nClasses));
                else
                    bootstrapData = DataSet.bootstrap(nBootstrapSamples);
                end
                
                if i == 1
                    Obj.Classifiers = train(Obj.baseClassifier,bootstrapData);
                else
                    Obj.Classifiers(i) = train(Obj.baseClassifier,bootstrapData);
                end
            end
        end
        
        function yOut = runAction(Obj,DataSet)
            yOut = DataSet;
            for i = 1:Obj.nBags
                Results = run(Obj.Classifiers(i),DataSet);
                if i == 1
                    yOut = yOut.setObservations(Results.getObservations);
                else
                    yOut = yOut.setObservations(yOut.getObservations + Results.getObservations);
                end
            end
            yOut = yOut.setObservations(yOut.getObservations./Obj.nBags);
        end
        
    end
    
end
