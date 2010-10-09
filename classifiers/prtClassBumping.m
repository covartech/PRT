classdef prtClassBumping < prtClass
    % prtClassBumping  Bumping (Bootstrap Selection) classifier
    %
    %  Botstrap the data nBags times, and choose the single best classifier
    %  based on the training data.  This is useful for processing data sets
    %  that may contain significant outliers.
    %
    % % Example:
    % ds = prtDataGenUnimodal;
    %  % add a significant outlier to the data:
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
    

    properties (SetAccess=private)
        % Required by prtAction
        name = 'Bumping'   %  Bagging Classifier
        nameAbbreviation = 'Bumping'  %  Bagging
        %isSupervised = true;          %  True
        
        isNativeMary = false;         % False
    end
    
    properties
        baseClassifier = prtClassFld('internalDecider',prtDecisionBinaryMinPe);  % The classifier to be bagged
        nBags = 100;                                    % The number of bags
        includeOriginalDataClassifier = false;          %run one additional classifier with the original data?  
                                                        %(Default to NO since this can give over trained results)
    end
    properties (SetAccess=protected)
        baggedPerformance
    end
    properties (SetAccess=protected, Hidden = true)
        Classifier 
    end
    
    methods
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
            [bestPerf,bestClassifier] = max(Obj.baggedPerformance);
            bestClassifier = bestClassifier(1);
            Obj.Classifier = Classifiers(bestClassifier);
            Obj.name = sprintf('%s (%s)',Obj.name,Obj.baseClassifier.name);
        end
        
        function yOut = runAction(Obj,DataSet)
            yOut = run(Obj.Classifier,DataSet);
        end
        
    end
    
end