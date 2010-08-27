classdef prtClassKmsd < prtClass
    % prtClassKmsd  Kernel matched subspace detector classifier
    %
    %    CLASSIFIER = prtClassKmsd returns a Kmsd classifier
    %
    %    CLASSIFIER = prtClassKmsd(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassKmsd object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassKmsd object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    sigma  - Inverse kernel width for guassian radial basis function
    % 
    %    For more information on Kmsd classifiers, refer to the
    %    following URL:
    %  
    %    http://ieeexplore.ieee.org/xpl/freeabs_all.jsp?arnumber=1561179
    %
    %    A prtClassKmsd object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT and
    %    PLOTDECISION classes from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassKmsd;              % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classes  = classified.getX > .5;
    %     percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassMaryEmulateOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassKmsd,  prtClass
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Kernel matched subspace detector'  % Kernel matched subspace detector
        nameAbbreviation = 'KMSD'  % KMSD
        isSupervised = true;  % True
        
        isNativeMary = false;   % False
    end
    properties (Access = private, Hidden = true)
        % Target libaray
        Zt = [];
        % Background library
        Zb = [];
        
        Ztb   = [];
        Delta = [];
        Beta  = [];
        Tau   = [];
        Kb_t  = [];
        Kt_b  = [];
        Kt_t  = [];
        Kb_b  = [];
    end
    
    properties
        sigma = .01;  % Kernel parameter for radial basis function   
    end
    
    methods
        function Obj = prtClassKMSD(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            %Obj.verboseStorage = false;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            Obj.Zt = DataSet.getObservationsByClass(1);
            Obj.Zb = DataSet.getObservationsByClass(0);
            
            Obj.Ztb = [Obj.Zt; Obj.Zb];
            
            % Compute Delta
            Ktb_tb = prtKernelRbf.rbfEvalKernel(Obj.Ztb,Obj.Ztb,Obj.sigma);
            [Obj.Delta eigD] = eig(Ktb_tb);
           
            eigD = diag(eigD);
            sumD = sum(eigD);
            eigNorm = eigD/sumD;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.9);   % 90% eigenvectors works well
            Obj.Delta = Obj.Delta(:,end-idx:end);
            
            
            % Compute Tau
            Obj.Kt_t = prtKernelRbf.rbfEvalKernel(Obj.Zt,Obj.Zt,Obj.sigma);
            [Obj.Tau, eigT] = eig(Obj.Kt_t);
            eigT = diag(eigT);
            sumT = sum(eigT);
            eigNorm = eigD/sumT;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.9);
            Obj.Tau = Obj.Tau(:,end-idx:end);
            
            
            % Compute Beta
            Obj.Kb_b = prtKernelRbf.rbfEvalKernel(Obj.Zb,Obj.Zb,Obj.sigma);
            [Obj.Beta, eigB] = eig(Obj.Kb_b);
            %Use eigenvectors that correspond to 90 of the information
            eigB = diag(eigB);
            sumB = sum(eigB);
            eigNorm = eigB/sumB;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.90);
            Obj.Beta = Obj.Beta(:,end-idx:end);
            
            % Compute these too just for fun
            Obj.Kb_t = prtKernelRbf.rbfEvalKernel(Obj.Zb,Obj.Zt,Obj.sigma);
            Obj.Kt_b = prtKernelRbf.rbfEvalKernel(Obj.Zt,Obj.Zb,Obj.sigma);
            
     end
        
        function ClassifierResults = runAction(Obj,DataSet)
            
            y = DataSet.getObservations();
            memLimSamples = 1000;
            if size(y,1) < memLimSamples
                dataOut = diag(prtClassKmsd.prtClassRunKMSD(Obj,y));
                ClassifierResults = prtDataSetClass(dataOut);
            else
                dataOut = [];
                maxSamples = size(y,1);
                currInd = 1;
                while currInd <= maxSamples
                    currIndices = currInd:min([currInd+memLimSamples-1,maxSamples]);
                    currData = y(currIndices,:);
                    dataOut = cat(1,dataOut,diag(prtClassKmsd.prtClassRunKMSD(Obj,currData)));
                    currInd = currInd + memLimSamples;
                end
                ClassifierResults = prtDataSetClass(dataOut);
            end
        end
        
    end
    methods (Static,Hidden = true)
        function LRT = prtClassRunKMSD(Obj,y)
            % Performs kmsd Classification on samples y. Zt is the target library. Zb is the
            % background library Sigma is the RBF parameter.
            
 
            % Compute the emperical kernel maps
            Ktb_y = prtKernelRbf.rbfEvalKernel(Obj.Ztb,y,Obj.sigma);
            Kb_y  = prtKernelRbf.rbfEvalKernel(Obj.Zb,y,Obj.sigma);
            Kt_y  = prtKernelRbf.rbfEvalKernel(Obj.Zt,y,Obj.sigma);
            
            % Compute the numerator of eq 32
            Num = Ktb_y'*(Obj.Delta*Obj.Delta')* Ktb_y - Kb_y'*(Obj.Beta*Obj.Beta')*Kb_y;
            
            % Compute Gamma1
            Gamma = [Obj.Tau'*Obj.Kt_t*Obj.Tau Obj.Tau'*Obj.Kt_b*Obj.Beta; Obj.Beta'*Obj.Kb_t*Obj.Tau Obj.Beta'*Obj.Kb_b*Obj.Beta];
            
            % Compute the denominator of eq 32
            %Den = Ktb_y'*(Obj.Delta*Obj.Delta')*Ktb_y - [Kt_y'*Obj.Tau Kb_y'*Obj.Beta] * inv(Gamma) * [Obj.Tau'*Kt_y;Obj.Beta'*Kb_y];
            Den = Ktb_y'*(Obj.Delta*Obj.Delta')*Ktb_y - [Kt_y'*Obj.Tau Kb_y'*Obj.Beta] /(Gamma) * [Obj.Tau'*Kt_y;Obj.Beta'*Kb_y];
            
            LRT = Num./Den;
        end
    end
end
