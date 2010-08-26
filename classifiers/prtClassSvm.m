classdef prtClassSvm < prtClass
       % prtClassSvm  Relevance vector machin classifier
    %
    %    CLASSIFIER = prtClassSvm returns a relevance vector machine classifier
    %
    %    CLASSIFIER = prtClassSvm(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassMAP object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassSvm object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    c      - Slack variable
    %    alpha  -
    %    beta   -
    %    tol    - tolerance
    %    For information on relevance vector machines, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/Support_vector_machine
    %
    %    A prtClassSvm object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUnimodal;      % Create some test and
    %     TrainingDataSet = prtDataGenUnimodal;  % training data
    %     classifier = prtClassSvm;           % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classes  = classified.getX > .5;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
    
    properties (SetAccess=private)
        name = 'Support Vector Machine'  % Support Vector Machine
        nameAbbreviation = 'SVM'         % SVM
        isSupervised = true; % True
        
        isNativeMary = false;  % False
    end
    
    properties
        
        c = 1; % Slack parameter
        tol = 0.00001;  % Tolerance
        alpha
        beta
        kernels = {prtKernelRbfNdimensionScale};  % Kernels
    end
    properties 
        trainedKernels   % Trained kernels
    end
    methods
        
        function Obj = prtClassSvm(varargin)
           
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            % Train (center) the kernels at the trianing data (if
            % necessary)
            Obj.trainedKernels = cell(size(Obj.kernels));
            for iKernel = 1:length(Obj.kernels);
                Obj.trainedKernels{iKernel} = initializeKernelArray(Obj.kernels{iKernel},DataSet);
            end
            Obj.trainedKernels = cat(1,Obj.trainedKernels{:});
            gramm = prtKernelGrammMatrix(DataSet,Obj.trainedKernels);
            
            [Obj.alpha,Obj.beta] = prtUtilSmo(DataSet.getX,DataSet.getY,gramm,Obj.c,Obj.tol);
            
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            
            memChunkSize = 1000; % Should this be moved somewhere?
            n = DataSet.nObservations;
            
            DataSetOut = prtDataSetClass(zeros(n,1));
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSetClass(DataSet.getObservations(cI,:));
                gramm = prtKernelGrammMatrix(cDataSet,Obj.trainedKernels);
                
                y = gramm*Obj.alpha - Obj.beta;
                DataSetOut = DataSetOut.setObservations(y, cI);
            end
        end
        
    end
    methods
        function varargout = plot(Obj)
            % plot - Plot output confidence of the prtClassSvm object
            %
            %   CLASS.plot plots the output confidence of the prtClassSvm
            %   object. The dimensionality of the dataset must be 3 or
            %   less, and verboseStorage must be true.
            
            HandleStructure = plot@prtClass(Obj);
            
            % Plot the kernels
            hold on
            for iKernel = 1:length(Obj.trainedKernels)
                if Obj.alpha(iKernel) ~= 0
                    Obj.trainedKernels{iKernel}.classifierPlot();
                end
            end
            hold off
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
    end
    
end