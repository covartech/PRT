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
        
                % Target libaray
        Zt = [];
        % Background library
        Zb = [];
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
            
            
        end
        
        function ClassifierResults = runAction(Obj,DataSet)
            
            y = DataSet.getObservations();
            memLimSamples = 1000;
            if size(y,1) < memLimSamples
                dataOut = diag(prtClassKmsd.prtClassRunKMSD(y, Obj.Zt, Obj.Zb, Obj.sigma));
                ClassifierResults = prtDataSet(dataOut);
            else
                dataOut = [];
                maxSamples = size(y,1);
                currInd = 1;
                while currInd <= maxSamples
                    currIndices = currInd:min([currInd+memLimSamples-1,maxSamples]);
                    currData = y(currIndices,:);
                    dataOut = cat(1,dataOut,diag(prtClassKmsd.prtClassRunKMSD(currData, Obj.Zt, Obj.Zb, Obj.sigma)));
                    currInd = currInd + memLimSamples;
                end
                ClassifierResults = prtDataSet(dataOut);
            end
        end
        
    end
    methods (Static)
        function LRT = prtClassRunKMSD(y, Zt, Zb ,sigma)
            % Performs kmsd Classification on samples y. Zt is the target library. Zb is the
            % background library Sigma is the RBF parameter.
            
            Ztb = [Zt; Zb];
            
            % Compute Delta
            Ktb_tb = rbfKernel(Ztb,Ztb,sigma);
            [Delta eigD] = eig(Ktb_tb);
            %Delta = Delta(:,end);
            eigD = diag(eigD);
            sumD = sum(eigD);
            eigNorm = eigD/sumD;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.9);
            Delta = Delta(:,end-idx:end);
            
            
            % Compute Tau
            Kt_t = rbfKernel(Zt,Zt,sigma);
            [Tau, eigT] = eig(Kt_t);
            eigT = diag(eigT);
            sumT = sum(eigT);
            eigNorm = eigD/sumT;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.9);
            Tau = Tau(:,end-idx:end);
            
            
            % Compute Beta
            Kb_b = rbfKernel(Zb,Zb,sigma);
            [Beta, eigB] = eig(Kb_b);
            %Use eigenvectors that correspond to 90 of the information
            eigB = diag(eigB);
            sumB = sum(eigB);
            eigNorm = eigB/sumB;
            eigPow = cumsum(flipud(eigNorm));
            idx = find(eigPow>.90);
            Beta = Beta(:,end-idx:end);
            
            % Compute these too just for fun
            Kb_t = rbfKernel(Zb,Zt,sigma);
            Kt_b = rbfKernel(Zt,Zb,sigma);
            
            % Compute the emperical kernel maps
            Ktb_y = rbfKernel(Ztb,y,sigma);
            Kb_y  = rbfKernel(Zb,y,sigma);
            Kt_y  = rbfKernel(Zt,y,sigma);
            
            % Compute the numerator of eq 32
            Num = Ktb_y'*(Delta*Delta')* Ktb_y - Kb_y'*(Beta*Beta')*Kb_y;
            
            % Compute Gamma1
            Gamma = [Tau'*Kt_t*Tau Tau'*Kt_b*Beta; Beta'*Kb_t*Tau Beta'*Kb_b*Beta];
            
            % Compute the denominator of eq 32
            Den = Ktb_y'*(Delta*Delta')*Ktb_y - [Kt_y'*Tau Kb_y'*Beta] * inv(Gamma) * [Tau'*Kt_y;Beta'*Kb_y];
            
            LRT = Num./Den;
        end
    end
end
