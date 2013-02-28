classdef prtClassBumping < prtClass
    %prtClassBumping Bumping (Bootstrap Selection) Classifier
    %
    %    CLASSIFIER = prtClassBumping returns a Bumping classifier
    %
    %    CLASSIFIER = prtClassBumping(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassBumping object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    % A prtClassBumping object inherits all properties from the abstract class
    % prtClass. In addition is has the following properties:
    %
    %      baseClassifier    - The base classifier to be re-trained with bootstrap
    %                          samples
    %      nBags             - The number of bagging samples to use
    %
    %      includeOriginalDataClassifier - Boolean value specifying whether to
    %                                      include a classifier trained with
    %                                      all the available data (not a
    %                                      bootstrap sample) in comparison.
    %                                      Defaults to "false" since training
    %                                      with all the available data can
    %                                      result in over-training.
    %
    % After training, a Bump classifier contains a field "Classifier" with the
    % best trained classification algorithm, and a vector baggedPerformance
    % with the percent correct found for each bagging sample.
    %
    % A Bumping classifier is a meta-classifier that chooses one of several
    % classifiers trained on a bootstrap sampled version of the input training
    % data.  In this case, the classifier chosen is the classifier trained on
    % the bootstrap sample that results in the smallest percent error when
    % tested on the original data set.  Bumping classifiers can be useful when
    % the data set under consideration has a small number of significant
    % outliers; some of the bagging samples will be free of at least some of
    % the outliers and may provide better generalization performance.
    %
    % For more information on Bumping classifiers, see:
    %  Hastie, Tibshirani, and Friedman, The Elements of Statistical Learning
    %  Theory.
    %
    % % Example:
    % ds = prtDataGenUnimodal;
    % % add a significant outlier to the data:
    % ds = ds.setXY(cat(1,ds.getObservations,[-30 -10]),cat(1,ds.getTargets,1));
    % fld = prtClassFld('internalDecider',prtDecisionBinaryMinPe);
    % fld = fld.train(ds);
    %
    % bumpingFld = prtClassBumping('baseClassifier',fld);
    % bumpingFld = bumpingFld.train(ds);
    %
    % subplot(2,1,1); plot(fld);
    % subplot(2,1,2); plot(bumpingFld);
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
        name = 'Bumping'  % Bumping
        nameAbbreviation = 'Bumping'  % Bumping
        isNativeMary = false;         % False
    end
    
    properties
        baseClassifier = prtClassFld('internalDecider',prtDecisionBinaryMinPe);  % The classifier to be bagged
        nBags = 100;                                    % The number of bags
        includeOriginalDataClassifier = false;          %Whether or not to run one additional classifier with the original data.  
                                                        %(Default to NO since this can give over trained results)
    end
    properties (SetAccess=protected)
        baggedPerformance
        Classifier 
    end
    
    methods
        function Obj = set.nBags(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val)
               error('prt:prtClassBumping:nBags','nBags must be a positive scalar integer'); 
            end
            Obj.nBags = val;
        end
        
        function Obj = set.includeOriginalDataClassifier(Obj,val)
            if ~prtUtilIsLogicalScalar(val);
               error('prt:prtClassBumping:includeOriginalDataClassifier','includeOriginalDataClassifier must be a logical scalar'); 
            end
            Obj.includeOriginalDataClassifier = val;
        end
        
        function Obj = set.baseClassifier(Obj,classifier)
            assert(isa(classifier,'prtClass'),'prt:prtClassBumping','baseClassifier must be a subclass of prtClass, but classifier provided was a %s',class(classifier));
            assert(classifier.includesDecision,'prt:prtClassBumping','baseClassifier must have in internal decision (non-empty internalDecider field), but classifier.includesDecision was false');
            Obj.baseClassifier = classifier;
        end
        function Obj = prtClassBumping(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            if ~DataSet.isBinary
                error('prtClassBumping:nonBinaryTraining','Input dataSet for prtClassBumping.train must be binary');
            end
            
            Obj.nameAbbreviation = sprintf('Bumping_{%s}',Obj.baseClassifier.nameAbbreviation);
            if Obj.includeOriginalDataClassifier
                titleString = sprintf('Building %d(+1) %s models...',Obj.nBags,Obj.baseClassifier.name);
            else
                titleString = sprintf('Building %d %s models...',Obj.nBags,Obj.baseClassifier.name);
            end
            waitHandle = prtUtilWaitbarWithCancel(titleString);
            Obj.baggedPerformance = nan(Obj.nBags+1,1);
            Classifiers = repmat(Obj.baseClassifier,Obj.nBags+1,1);
            for i = 1:Obj.nBags+1
                waitHandle = prtUtilWaitbarWithCancel(i./Obj.nBags,waitHandle);
                
                if i == Obj.nBags + 1 && Obj.includeOriginalDataClassifier
                    %the full model; see "The Elements of Statistical Learning"
                    Classifiers(i) = train(Obj.baseClassifier,DataSet);
                    Obj.baggedPerformance(i) = prtScorePercentCorrect(Classifiers(i).run(DataSet),DataSet);
                elseif i < Obj.nBags+1
                    Classifiers(i) = train(Obj.baseClassifier,DataSet.bootstrap(DataSet.nObservations));
                    Obj.baggedPerformance(i) = prtScorePercentCorrect(Classifiers(i).run(DataSet),DataSet);
                end
                if ~ishandle(waitHandle)
                    break;
                end
            end
            
            if ishandle(waitHandle)
                delete(waitHandle);
            end
            [bestPerf,bestClassifier] = max(Obj.baggedPerformance); %#ok<ASGLU>
            bestClassifier = bestClassifier(1);
            Obj.Classifier = Classifiers(bestClassifier);
            Obj.name = sprintf('%s (%s)',Obj.name,Obj.baseClassifier.name);
        end
        
        function yOut = runAction(Obj,DataSet)
            yOut = run(Obj.Classifier,DataSet);
        end
        
    end
    
end
