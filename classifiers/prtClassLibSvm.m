classdef prtClassLibSvm < prtClass
    % prtClassLibSvm  Support vector machine classifier using LibSvm
    %
    %   CLASSIFIER = prtClassLibSvm returns a SVM Classifier using the
    %   SVM toolbox "LibSvm" which provides a fast interface to training
    %   and testing support vector machines.
    %
    %   Note: requires libSvm, which should be in nfPrt\util\libsvm-mat-2.91-1
    %   On linux, you may need to re-build the LibSVM Binaries.  See the
    %   documentation for LibSvm (link below) for more information.
    %
    %    A prtClassLibSvm object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties; complete
    %    documentation for these properties can be found here:
    %
    %       http://www.csie.ntu.edu.tw/~cjlin/libsvm/
    %
    %         svmType       - Whether to use a C-SVM, nu-SVM, one-class
    %                        SVM, epsilon-SVR, or nu-SVR
    %         kernelType    - Kernel type to use - linear, polynomial, rbf,
    %                        or sigmoid 
    %         degree        - Kernel function parameter (some kernels)
    %         gamma         - Kernel function parameter (some kernels)
    %         coef0         - Kernel function parameter (some kernels)
    %         cost          - Cost parameter
    %         nu            - nu parameter (nu-SVM's)
    %         pEpsilon      - Loss function parameter (epsilon-SVMs)
    %         cachesize     - Memory cache in MB (can affect speed,
    %                        computer dependent)
    %         eEpsilon      - Termination tolerance
    %         shrinking     - Use shrinking heuristic?
    %         probabilityEstimates - Output probability estimates?
    %         weight        - Parameter in C-SCM
    %
    %   Default values are:
    %     svmType = 0;
    %     kernelType = 2;
    %     degree = 3;
    %     gamma = nan;
    %     coef0 = 0;
    %     cost = 1;
    %     nu = .5;
    %     pEpsilon = .1;
    %     cachesize = 100;
    %     eEpsilon = 0.001;
    %     shrinking = 1;
    %     probabilityEstimates = 0;
    %     weight = 1;
    %
    %   Additional options can be specified by modifying the field 
    %   obj.libSvmOptions using the format found here:
    %   http://www.csie.ntu.edu.tw/~cjlin/libsvm/
    %
    %   More documentation can be found here:
    %   http://www.csie.ntu.edu.tw/~cjlin/papers/libsvm.pdf
    %
    %   Note: the LibSvm will output estimated percent correct values to
    %   the screen during processing; because of the way the PRT trains and
    %   tests, these should be ignored during training and plotting. (To be
    %   fixed)
    %
    %   %Example usage:
    %     TestDataSet = prtDataGenUnimodal;       % Create some test and
    %     TrainingDataSet = prtDataGenUnimodal;   % training data
    %     classifier = prtClassLibSvm;              % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     percentCorr = prtScorePercentCorrect(classified,TestDataSet);
    %     subplot(2,1,1);
    %     classifier.plot;
    %     subplot(2,1,2);
    %     [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %     h = plot(pf,pd,'linewidth',3);
    %     title('ROC'); xlabel('Pf'); ylabel('Pd');
    
    %   Notes for doc:
    %       1) The goddamn thing always outputs something like:
    %   Accuracy = 62.63% (6263/10000) (classification)
    %   when you try and run it on an unlabeled data set (in testing) or
    %   when you plot it.  This is because whoever made the interface
    %   didn't think to give us a way that I can see to turn off that
    %   output.
    %
    %       2) All the parameters that you set below actually get set for
    %       real when we call libSvmOptionString and libSvmOptionStringTest
    %       in train.  The calling syntax is command-line-esque, but I
    %       think I check for all the right requirements.
    %
    %
    
    properties (SetAccess=private)
        name = 'LibSVM Support Vector Machine'  % Support Vector Machine
        nameAbbreviation = 'LibSVM'         % SVM
        isNativeMary = false;  % False
    end
    
    properties
        
        svmType = 0;
        kernelType = 2;
        degree = 3;
        gamma = nan;
        coef0 = 0;
        cost = 1;
        nu = .5;
        pEpsilon = .1;
        cachesize = 100;
        eEpsilon = 0.001;
        shrinking = 1;
        probabilityEstimates = 0;
        weight = 1;
        
        libSvmOptions = '';
    end
    properties (Hidden = true)
        %Note, the libSvm has different opinions of what classes 1 and 0
        %mean than we do; gain takes care of the difference.
        gain = 1; 
        trainedSvm 
        libSvmOptionsTest
    end
    
    methods
        function obj = set.svmType(obj,val)
            assert(isscalar(val) && ismember(val,[0 1 2 3 4]),'svmType must be one of 0,1,2,3,4; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.svmType = val;
        end
        function obj = set.kernelType(obj,val)
            assert(isscalar(val) && ismember(val,[0 1 2 3]),'kernelType must be one of 0,1,2,3; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.kernelType = val;
        end
        function obj = set.degree(obj,val)
            assert(isscalar(val) && prtUtilIsPositiveInteger(val),'degree must be a positive integer; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.degree = val;
        end
        function obj = set.gamma(obj,val)
            if ischar(val)
                obj.gamma = val;
            else
                assert(isscalar(val) && val > 0,'gamma must be a positive value; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
                obj.gamma = val;
            end
        end
        function obj = set.coef0(obj,val)
            assert(isscalar(val),'coef0 must be a scalar; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.coef0 = val;
        end
        function obj = set.cost(obj,val)
            assert(isscalar(val) && val > 0,'cost must be a positive value; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.cost = val;
        end
        function obj = set.nu(obj,val)
            assert(isscalar(val) && val > 0,'nu must be a positive value; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.nu = val;
        end
        function obj = set.pEpsilon(obj,val)
            assert(isscalar(val) && val > 0,'pEpsilon must be a positive value; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.pEpsilon = val;
        end
        function obj = set.cachesize(obj,val)
            assert(isscalar(val) && val > 0,'cachesize must be a positive value; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.cachesize = val;
        end
        function obj = set.eEpsilon(obj,val)
            assert(isscalar(val) && val > 0,'eEpsilon must be a positive value; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.eEpsilon = val;
        end
        function obj = set.shrinking(obj,val)
            val = double(val);
            assert(isscalar(val) && ismember(val,[0 1]),'shrinking must be one of 0,1; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.shrinking = val;
        end
        function obj = set.probabilityEstimates(obj,val)
            val = double(val);
            assert(isscalar(val) && ismember(val,[0 1]),'probabilityEstimates must be one of 0,1; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.probabilityEstimates = val;
        end
        function obj = set.weight(obj,val)
            assert(isscalar(val) && val > 0,'weight must be a positive value; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.weight = val;
        end
        
        function Obj = prtClassLibSvm(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end    
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            training_label_vector = DataSet.getTargets;
            training_instance_matrix = DataSet.getObservations;
            Obj.libSvmOptions = Obj.libSvmOptionString(DataSet);
            Obj.libSvmOptionsTest = Obj.libSvmOptionStringTest(DataSet);
            
            Obj.trainedSvm = svmtrain(training_label_vector, training_instance_matrix, Obj.libSvmOptions);
            
            %Need to figure out whether to flip SVM outputs:
            yOut = runAction(Obj,DataSet);
            auc = prtScoreAuc(yOut.getObservations,DataSet.getTargets);
            if auc < .5
                Obj.gain = -1;
            end
        end
        
        function DataSetOut = runAction(Obj,DataSet)

            testing_label_vector = DataSet.getTargets;
            if isempty(testing_label_vector)
                testing_label_vector = zeros(DataSet.nObservations,1);
                disp('Ignore predicted accuracy:');
            else
                disp('Testing predicted accuracy:');
            end
            testing_instance_matrix = DataSet.getObservations;
            [dontNeed, dontNeed, decision_values] = svmpredict(testing_label_vector, testing_instance_matrix, Obj.trainedSvm, Obj.libSvmOptionsTest); %#ok<ASGLU>
            
            DataSetOut = DataSet;
            DataSetOut = DataSetOut.setObservations(decision_values*Obj.gain);
        end
        
    end
    methods (Hidden = true)
        function optionString = libSvmOptionString(obj,dataSet)
            if isnan(obj.gamma)
                obj.gamma = 1./dataSet.nFeatures;
            elseif ischar(obj.gamma)
                obj.gamma = strrep(obj.gamma,'k',sprintf('%d',dataSet.nFeatures));
                obj.gamma = eval(obj.gamma);
            end
            optionString = sprintf('-s %d -t %d -d %d -g %f -r %f -c %f -n %f -p %f -m %f -e %f -h %d -b %d -wi %f',...
                obj.svmType,obj.kernelType,obj.degree,obj.gamma,obj.coef0,obj.cost,obj.nu,...
                obj.pEpsilon,obj.cachesize,obj.eEpsilon,obj.shrinking,obj.probabilityEstimates,obj.weight);
        end
        function optionString = libSvmOptionStringTest(obj,dataSet) %#ok<INUSD>
            optionString = sprintf('-b %d',obj.probabilityEstimates);
        end
    end
end