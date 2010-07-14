classdef prtClassKmsd < prtClass
    % prtClassKmsd - Kernel matched subspace classification
    % object.
    %
    % prtClassGlrt Properties:
    %   sigma - sigma for guassian radial basis function
    %
    %
    % prtClassGlrt Methods:
    %   prtClassKmsd - Kmsd constructor
    %   train - Kmsd training; see prtAction.train
    %   run - Kmsd evaluation; see prtAction.run
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Kernel Matched Subspace detector'
        nameAbbreviation = 'KMSD'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
    end
    properties (Access = private)
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
 
        sigma = .01;
        

    end
    
    methods
        function Obj = prtClassKMSD(varargin)
            %Glrt = prtClassKMSD(varargin)
            %   The KMSD constructor allows the user to use name/property
            % pairs to set public fields of the KMSD classifier.
            %
            %   For example:
            %
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            %Obj.verboseStorage = false;
        end
    end
    
    methods (Access=protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            Obj.Zt = DataSet.getObservationsByClass(1);
            Obj.Zb = DataSet.getObservationsByClass(0);
            
            Obj.Ztb = [Obj.Zt; Obj.Zb];
            
            % Compute Delta
            Ktb_tb = rbfKernel(Obj.Ztb,Obj.Ztb,Obj.sigma);
            [Obj.Delta eigD] = eig(Ktb_tb);
           
            eigD = diag(eigD);
            sumD = sum(eigD);
            eigNorm = eigD/sumD;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.9);   % 90% eigenvectors works well
            Obj.Delta = Obj.Delta(:,end-idx:end);
            
            
            % Compute Tau
            Obj.Kt_t = rbfKernel(Obj.Zt,Obj.Zt,Obj.sigma);
            [Obj.Tau, eigT] = eig(Obj.Kt_t);
            eigT = diag(eigT);
            sumT = sum(eigT);
            eigNorm = eigD/sumT;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.9);
            Obj.Tau = Obj.Tau(:,end-idx:end);
            
            
            % Compute Beta
            Obj.Kb_b = rbfKernel(Obj.Zb,Obj.Zb,Obj.sigma);
            [Obj.Beta, eigB] = eig(Obj.Kb_b);
            %Use eigenvectors that correspond to 90 of the information
            eigB = diag(eigB);
            sumB = sum(eigB);
            eigNorm = eigB/sumB;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.90);
            Obj.Beta = Obj.Beta(:,end-idx:end);
            
            % Compute these too just for fun
            Obj.Kb_t = rbfKernel(Obj.Zb,Obj.Zt,Obj.sigma);
            Obj.Kt_b = rbfKernel(Obj.Zt,Obj.Zb,Obj.sigma);
            
            
            
            
        end
        
        function ClassifierResults = runAction(Obj,DataSet)
            
            y = DataSet.getObservations();
            memLimSamples = 1000;
            if size(y,1) < memLimSamples
                dataOut = diag(prtClassKmsd.prtClassRunKMSD(Obj,y));
                ClassifierResults = prtDataSet(dataOut);
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
                ClassifierResults = prtDataSet(dataOut);
            end
        end
        
    end
    methods (Static)
        function LRT = prtClassRunKMSD(Obj,y)
            % Performs kmsd Classification on samples y. Zt is the target library. Zb is the
            % background library Sigma is the RBF parameter.
            
 
            % Compute the emperical kernel maps
            Ktb_y = rbfKernel(Obj.Ztb,y,Obj.sigma);
            Kb_y  = rbfKernel(Obj.Zb,y,Obj.sigma);
            Kt_y  = rbfKernel(Obj.Zt,y,Obj.sigma);
            
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
