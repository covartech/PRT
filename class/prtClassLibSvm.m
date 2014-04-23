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
    %         kernelType    - Kernel type to use - linear (0), polynomial (1),
    %                         rbf (2, default), sigmoid (3), or
    %                         user-defined (4) - see below
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
    %         weight        - Class-specific weight parameter in C-SCM
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
    %     weight = [1 1];
    %
    %     userSpecKernel = [];  %only for kernelType = 4, see below
    %
    %   prtClassLibSvm allows the specification of user-defined kernels by
    %   setting svm.kernelType to 4.  This requires further specification
    %   of svm.userSpecKernel.  svm.userSpecKernel must be either a
    %   function handle, fn(x,y) which outputs a matrix of size 
    %   size(x,1) x size(y,1), or userSpecKernel can be a prtKernel object.
    %
    %   For example:
    %     svm.kernelType = 4;
    %     svm.userSpecKernel = @(x,y) (x*y'); % correlation kernel
    %  
    %     svm.kernelType = 4;
    %     svm.userSpecKernel = prtKernelHyperbolicTangent; 
    %
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


    %   Notes for doc:
    %       1) The LIBSVM Matlab interface always outputs something like:
    %   Accuracy = 62.63% (6263/10000) (classification)
    %   when you try and run it on an unlabeled data set (in testing) or
    %   when you plot it.  This is because whoever made the interface
    %   didn't think to give us a way that I can see to turn off that
    %   output. (Actually this has now been disabled.)
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
        weight = [1 1];
        
        libSvmOptions = '';
        
        userSpecKernel = [];
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
            assert(isscalar(val) && ismember(val,[0 1 2 3 4]),'kernelType must be one of 0,1,2,3,4; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.kernelType = val;
        end
        function obj = set.degree(obj,val)
            assert(isscalar(val) && prtUtilIsPositiveInteger(val),'degree must be a positive integer; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.degree = val;
        end
        function obj = set.gamma(obj,val)
            if isnan(val)
                return
            end
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
            assert(numel(val)==2 && all(val > 0),'weight must be a positive 2-element vector; see the instructions at http://www.csie.ntu.edu.tw/~cjlin/libsvm/ for more information');
            obj.weight = val;
        end
        
        function self = prtClassLibSvm(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end    
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            % Its ok to have 1 class if its a 1 class classifier
            if dataSet.nClasses ~= 2 && self.svmType ~=2
                error('prt:prtClassLibSvm:UnaryData','prtClassLibSvm requires binary data for training');
            end
            if dataSet.nClasses ~= 1 && self.svmType ==2
                % You can avoid this warning using
                % prtOutlierRemovalFnTargets in your algorithm spec. 
                warning('prt:prtClassLibSvm:UnaryData','prtClassLibSvm requires unary data for training when svmType = 2; using max(dataSet.uniqueClasses) as the default single class.');
                dataSet = dataSet.retainClasses(max(dataSet.uniqueClasses));
            end
            
            training_label_vector = dataSet.getTargetsAsBinaryMatrix;
            training_label_vector = double(training_label_vector(:,end)); %zeros and ones
            training_instance_matrix = dataSet.getObservations;
            self.libSvmOptions = self.libSvmOptionString(dataSet);
            self.libSvmOptionsTest = self.libSvmOptionStringTest(dataSet);
            
            if self.kernelType == 4
                %self.userSpecKernel = prtKernelRbfNdimensionScale;
                if ~isa(self.userSpecKernel,'prtKernel') && ~isa(self.userSpecKernel,'function_handle')
                    error('prtClassLibSvm:KernelType4','For kernelType = 4 (user-specified kernel), svm.userSpecKernel must be a prtKernel or function handle');
                end
                if isa(self.userSpecKernel,'prtKernel')
                    self.userSpecKernel = self.userSpecKernel.train(dataSet);
                    kernelMat = self.userSpecKernel.run(dataSet);
                    training_instance_matrix = kernelMat.data;
                else
                    training_instance_matrix = self.userSpecKernel(dataSet.X,dataSet.X);
                end
                training_instance_matrix = cat(2,(1:size(training_instance_matrix,1))',training_instance_matrix);
            end            
            self.trainedSvm = prtExternal.libsvm.svmtrain(training_label_vector, training_instance_matrix, self.libSvmOptions);
            
            %Need to figure out whether to flip SVM outputs:
            yOut = runAction(self,dataSet);
            auc = prtScoreAuc(yOut.retainLabeled);
            
            %libSVM has some weird rules about target names.  the first target type it finds is called H1...
            % We can fix this either above, or here
            if auc < .5  
                self.gain = -1;
            end
        end
        
        function DataSetOut = runAction(self,dataSet)

            testing_label_vector = double(dataSet.getTargets);
            if isempty(testing_label_vector)
                testing_label_vector = zeros(dataSet.nObservations,1);
            end
            
            if self.kernelType == 4
                if ~isa(self.userSpecKernel,'prtKernel') && ~isa(self.userSpecKernel,'function_handle')
                    error('prtClassLibSvm:KernelType4','For kernelType = 4 (user-specified kernel), svm.userSpecKernel must be a prtKernel or function handle');
                end
                if isa(self.userSpecKernel,'prtKernel')
                    kernelMat = self.userSpecKernel.run(dataSet);
                    testing_instance_matrix = kernelMat.data;
                else
                    %Function handle:
                    testing_instance_matrix = self.userSpecKernel(dataSet.X,self.dataSet.X);
                end
                testing_instance_matrix = cat(2,(1:size(testing_instance_matrix,1))',testing_instance_matrix);
            else
                testing_instance_matrix = dataSet.getObservations;
            end
            
            [dontNeed, dontNeed, decision_values] = prtExternal.libsvm.svmpredict(testing_label_vector, testing_instance_matrix, self.trainedSvm, self.libSvmOptionsTest); %#ok<ASGLU>
            
            DataSetOut = dataSet;
            DataSetOut = DataSetOut.setObservations(decision_values*self.gain);
        end
        
        function dataSetOut = runActionFast(self,x,ds)
            
            switch self.kernelType
                case 2
                    nFeats = size(x,2);
                    f = full(self.trainedSvm.SVs);
                    gram = prtKernelRbf.kernelFn(f,x,sqrt(nFeats));
                    yOut = ((self.trainedSvm.sv_coef'*gram)-self.trainedSvm.rho)';
                otherwise
                    error('prt:prtClassLibSvm','Unsupported kernel type for runActionFast');
            end
            dataSetOut = yOut(:)*self.gain;
        end
        
    end
    methods (Hidden = true)
        
        function str = textSummary(self)
            str = sprintf('%s: \n',class(self));
            str2 = evalc('disp(self.trainedSvm)');
            str = sprintf('%s%s',str,str2);
        end
        function optionString = libSvmOptionString(obj,dataSet)
            if isnan(obj.gamma)
                obj.gamma = 1./dataSet.nFeatures;
            end
            if ischar(obj.gamma)
                optionString = sprintf('-s %d -t %d -d %d -g %s -r %f -c %f -n %f -p %f -m %f -e %f -h %d -b %d -w0 %f -w+1 %f',...
                    obj.svmType,obj.kernelType,obj.degree,obj.gamma,obj.coef0,obj.cost,obj.nu,...
                    obj.pEpsilon,obj.cachesize,obj.eEpsilon,obj.shrinking,obj.probabilityEstimates,obj.weight(1),obj.weight(2));
            else
                optionString = sprintf('-s %d -t %d -d %d -g %f -r %f -c %f -n %f -p %f -m %f -e %f -h %d -b %d -w0 %f -w+1 %f',...
                    obj.svmType,obj.kernelType,obj.degree,obj.gamma,obj.coef0,obj.cost,obj.nu,...
                    obj.pEpsilon,obj.cachesize,obj.eEpsilon,obj.shrinking,obj.probabilityEstimates,obj.weight(1),obj.weight(2));
            end
        end
        function optionString = libSvmOptionStringTest(obj,dataSet) %#ok<INUSD>
            optionString = sprintf('-b %d',obj.probabilityEstimates);
        end
    end
        
    methods (Hidden)
        function str = exportSimpleText(self) %#ok<MANU>
            titleText = sprintf('%% prtClassLibSvm\n');
            svmSvText = prtUtilMatrixToText(full(self.trainedSvm.SVs),'varName','supportVectors');
            svmSvCoeffText = prtUtilMatrixToText(full(self.trainedSvm.sv_coef),'varName','svCoefficients');
            svmSigmaText = prtUtilMatrixToText(sqrt(size(self.trainedSvm.SVs,2)),'varName','sigma');
            svmRhoText = prtUtilMatrixToText(self.trainedSvm.rho,'varName','rho');
            str = sprintf('%s%s%s%s%s',titleText,svmSvText,svmSvCoeffText,svmSigmaText,svmRhoText);
        end
    end
end

