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
 %    rvs    - A prtRv*. This property describes the random variable 
 %             model used for Maximum a Posteriori classification. To
 %             change the type of model used, edit this field and set the
 %             field to the type of prtRv you'd like to use, then run the
 %             train method
 %
 %    A prtClassMap object inherits inherits the TRAIN, RUN, CROSSVALIDATE
 %    and KFOLDS methods from prtClass.
 %
 %    Example:
 %
 %    TestDataSet = prtDataGenUnimodal;       % Create some test and
 %    TrainingDataSet = prtDataGenUnimodal;   % training data
 %    classifier = prtClassMap;           % Create a classifier
 %    classifier = classifier.train(TrainingDataSet);    % Train
 %    classified = run(classifier, TestDataSet);         % Test
 %    subplot(2,1,1);
 %    classifier.plot;
 %    subplot(2,1,2);
 %    [pf,pd] = prtScoreRoc(classified,TestDataSet);
 %    h = plot(pf,pd,'linewidth',3);
 %    title('ROC'); xlabel('Pf'); ylabel('Pd');
 %
 %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
 %    prtClassMap, prtClassFld, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
 %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClassSvm,
 %    prtClassTreeBaggingCap, prtClassKmsd, prtClassKnn                   

    properties (SetAccess=private)
        % Required by prtAction
        name = 'Maximum a Posteriori'   % Maximum a Posteriori
        nameAbbreviation = 'MAP'        % MAP
        isNativeMary = true;            % True
    end
    
    properties
      
        rvs = prtRvMvn; % Random variable object containing mean and variance
    end
    
    methods
        % Constructor
        function Obj = prtClassMap(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        % Set function
        function Obj = set.rvs(Obj,val)
            if(~ isa(val, 'prtRv'))
                error('prtClassMAP:rvs','Rvs parameter must be of class prtRv');
            else
                Obj.rvs = val;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            % Repmat the rv objects to get one for each class
            Obj.rvs = repmat(Obj.rvs(:), (DataSet.nClasses - length(Obj.rvs)+1),1);
            Obj.rvs = Obj.rvs(1:DataSet.nClasses);

            % Get the ML estimates of the RV parameters for each class
            for iY = 1:DataSet.nClasses
                Obj.rvs(iY) = mle(Obj.rvs(iY), DataSet.getObservationsByClassInd(iY));
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            logLikelihoods = zeros(DataSet.nObservations, length(Obj.rvs));
            for iY = 1:length(Obj.rvs)
                logLikelihoods(:,iY) = logPdf(Obj.rvs(iY), DataSet.getObservations());
            end

            % Change to posterior probabilities and package everything up in a
            % prtDataSet
            DataSet = prtDataSetClass(exp(bsxfun(@minus, logLikelihoods, prtUtilSumExp(logLikelihoods.').')));
            DataSet.UserData.logLikelihoods = logLikelihoods;
        end
        
    end
    
end