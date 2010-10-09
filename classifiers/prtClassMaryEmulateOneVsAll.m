classdef prtClassMaryEmulateOneVsAll < prtClass
    % prtClassMaryEmulateOneVsAll  M-Ary Emulation Classifier
    %
    %    CLASSIFIER = prtClassMaryEmulateOneVsAll returns a M-ary one
    %    versus all classifier. A one versus all classifier utilizes a
    %    binary classifier to make M-ary decisions. For all M classes, it
    %    selects one class, and makes a binary comparison to all the
    %    others.
    %
    %    CLASSIFIER = prtClassMaryEmulateOneVsAll(PROPERTY1, VALUE1, ...)
    %    constructs a prtClassMAP object CLASSIFIER with properties as
    %    specified by PROPERTY/VALUE pairs.
    %
    %    A prtClassMaryEmulateOneVsAll object inherits all properties from the
    %    abstract class prtClass. In addition is has the following
    %    properties:
    %
    %    Classifiers - The classifier to be used to make the binary
    %                  decisions. Must be a prtClass object, and defaults 
    %                  to a prtClassLogisticDiscriminant classifier.
    % 
    %    A prtClassMaryEmulateOneVsAll object inherits the TRAIN, RUN,
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits
    %    the PLOT and PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenMary;      % Create some test and 
    %     TrainingDataSet = prtDataGenMary;  % training data
    %     classifier = prtClassMaryEmulateOneVsAll; % Create a classifier
    %     classifier.Classifiers = prtClassGlrt;    % Set the binary 
    %                                               % Classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     [~, classes] = max(classified.getX,[],2);          % Select the
    %                                                        % classes
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    properties (SetAccess=private)
        name = 'M-Ary Emaulation One vs. All'  % M-Ary Emaulation One vs. All
        nameAbbreviation = 'OneVsAll'  % OVA
        isNativeMary = true;  % True
    end
    
    properties
        Classifiers = prtClassLogisticDiscriminant; % The classifier to be used
    end
    
    methods
        
        function Obj = prtClassMaryEmulateOneVsAll(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected,Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            % Repmat the Classifier objects to get one for each class
            Obj.nameAbbreviation = sprintf('OneVsAll_{%s}',Obj.Classifiers(1).nameAbbreviation);
            Obj.Classifiers = repmat(Obj.Classifiers(:), (DataSet.nClasses - length(Obj.Classifiers)+1),1);
            Obj.Classifiers = Obj.Classifiers(1:DataSet.nClasses);
            
            for iY = 1:DataSet.nClasses
                % Replace the targets with binary targets for this class
                cDataSet = DataSet.setTargets(DataSet.getTargetsAsBinaryMatrix(:,iY));
                
                % We need the classifier to act like a binary and we dont 
                % want a bunch of DataSets lying around
                Obj.Classifiers(iY).verboseStorage = false;
                Obj.Classifiers(iY).twoClassParadigm = 'binary';
                
                % Train this Classifier
                Obj.Classifiers(iY) = train(Obj.Classifiers(iY), cDataSet);
            end
        end

        function DataSetOut = runAction(Obj,DataSet)
            DataSetOut = prtDataSetClass(zeros(DataSet.nObservations, length(Obj.Classifiers)));
            
            for iY = 1:length(Obj.Classifiers)
                cOutput = run(Obj.Classifiers(iY), DataSet);
                
                DataSetOut = DataSetOut.setObservations(cOutput.getObservations(),:,iY);
            end
        end
        
    end
    
end