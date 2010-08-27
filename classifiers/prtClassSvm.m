classdef prtClassSvm < prtClass
    % prtClassSvm  Support vector machine classifier
    %
    %    CLASSIFIER = prtClassSvm returns a support vector machine classifier
    %
    %    CLASSIFIER = prtClassSvm(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassSvm object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassSvm object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %   SetAccess = public:
    %    c      - Slack variable weight (see prtUtilSmo for reference)
    %    tol    - tolerance on learning updates (see prtUtilSmo for reference)
    %
    %   SetAccess = private/protected:
    %    alpha  - vector of SVM weights
    %    beta   - SVM DC offset
    %
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
    %     TestDataSet = prtDataGenUniModal;      % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;  % training data
    %     classifier = prtClassSvm;              % Create a classifier
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
        kernels = {prtKernelRbfNdimensionScale};  % Kernels
    end
    properties (SetAccess = 'protected',GetAccess = 'public')
        alpha 
        beta
    end
    properties 
        trainedKernels   % Trained kernels
    end
    methods
        
        function Obj = set.kernels(Obj,val)
            if ~isa(val,'cell')
                val = {val};
            end
            assert(isscalar(val),'prt:prtClassRvm:setKernels','kernels must be a 1x1 prtKernel or a 1x1 cell containing one prtKernel object');
            assert(isa(val{1},'prtKernel'),'prt:prtClassRvm:setKernels','kernels must be a 1x1 cell array of prtKernels, but value{1} is a %s',class(val{1}));
            Obj.kernels = val;
        end
        function Obj = set.c(Obj,val)
            assert(isscalar(val) && isnumeric(val) && val > 0,'prt:prtClassSvm:c','c must be a scalar greater than 0, but value provided is %s',mat2str(val));
            Obj.c = val;
        end
        function Obj = set.tol(Obj,val)
            assert(isscalar(val) && isnumeric(val) && val > 0,'prt:prtClassSvm:tol','tol must be a scalar greater than 0, but value provided is %s',mat2str(val));
            Obj.tol = val;
        end
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