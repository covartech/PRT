classdef prtClassBinaryToMaryOneVsAll < prtClass
    % prtClassBinaryToMaryOneVsAll  M-Ary Emulation Classifier
    %
    %    CLASSIFIER = prtClassBinaryToMaryOneVsAll returns a M-ary "one
    %    versus all" classifier. A one versus all classifier utilizes a
    %    binary classifier to make M-ary decisions. For all M classes, it
    %    selects each class, and makes a binary comparison to all the
    %    others.
    %
    %    CLASSIFIER = prtClassBinaryToMaryOneVsAll(PROPERTY1, VALUE1, ...)
    %    constructs a prtClassBinaryToMaryOneVsAll object CLASSIFIER with
    %    properties as specified by PROPERTY/VALUE pairs.
    %
    %    A prtClassBinaryToMaryOneVsAll object inherits all properties from the
    %    abstract class prtClass. In addition is has the following
    %    properties:
    %
    %    baseClassifier - The classifier to be used to make the binary
    %                  decisions. Must be a prtClass object, and defaults 
    %                  to a prtClassLogisticDiscriminant classifier.
    % 
    %    A prtClassBinaryToMaryOneVsAll object inherits the TRAIN, RUN,
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits
    %    the PLOT method from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenMary;      % Create some test and 
    %     TrainingDataSet = prtDataGenMary;  % training data
    %     classifier = prtClassBinaryToMaryOneVsAll;   % Create a classifier
    %     classifier.baseClassifier = prtClassGlrt;    % Set the binary 
    %                                                  % Classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     [~, classes] = max(classified.getX,[],2);          % Select the
    %                                                        % classes
    %     % Evaluate, plot results
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets)
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    properties (SetAccess=private)
        name = 'M-Ary Emaulation One vs. All'  % M-Ary Emaulation One vs. All
        nameAbbreviation = 'OneVsAll'  % OVA
        isNativeMary = true;  % True
    end
    
    properties
        baseClassifier = prtClassLogisticDiscriminant; % The classifier to be used
    end
    
    methods
        
        function Obj = prtClassBinaryToMaryOneVsAll(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.baseClassifier(Obj,classifier)
            if ~isa(classifier,'prtClass')
                error('prt:prtClassBinaryToMaryOneVsAll','baseClassifier must be a subclass of prtClass, but classifier provided was a %s',class(classifier));
            end
            Obj.baseClassifier = classifier;
        end
    end
    
    methods (Access = protected,Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            % Repmat the Classifier objects to get one for each class
            Obj.nameAbbreviation = sprintf('OneVsAll_{%s}',Obj.baseClassifier(1).nameAbbreviation);
            Obj.baseClassifier = repmat(Obj.baseClassifier(:), (DataSet.nClasses - length(Obj.baseClassifier)+1),1);
            Obj.baseClassifier = Obj.baseClassifier(1:DataSet.nClasses);
            
            actuallyShowProgressBar = Obj.showProgressBar && (DataSet.nClasses > 1);
            
            if actuallyShowProgressBar
                waitBarObj = prtUtilProgressBar(0,'Training M-Ary Emulation Classifier (One vs. All)','autoClose',true);
            end
            
            for iY = 1:DataSet.nClasses
                if actuallyShowProgressBar
                    waitBarObj.update((iY-1)/DataSet.nClasses);
                end
                
                % Replace the targets with binary targets for this class
                cDataSet = DataSet.setTargets(DataSet.getTargetsAsBinaryMatrix(:,iY));
                
                % We need the classifier to act like a binary and we dont 
                % want a bunch of DataSets lying around
                Obj.baseClassifier(iY).verboseStorage = false;
                Obj.baseClassifier(iY).twoClassParadigm = 'binary';
                
                % Train this Classifier
                Obj.baseClassifier(iY) = train(Obj.baseClassifier(iY), cDataSet);
            end
            if actuallyShowProgressBar
                waitBarObj.update(1);
            end
            
        end

        function DataSetOut = runAction(Obj,DataSet)
            DataSetOut = prtDataSetClass(zeros(DataSet.nObservations, length(Obj.baseClassifier)));
            
            for iY = 1:length(Obj.baseClassifier)
                cOutput = run(Obj.baseClassifier(iY), DataSet);
                
                DataSetOut = DataSetOut.setObservations(cOutput.getObservations(),:,iY);
            end
        end
        
    end
    
end