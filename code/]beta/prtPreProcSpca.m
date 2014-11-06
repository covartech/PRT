classdef prtPreProcSpca < prtPreProc

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


    %
    % [DataSet,A,S] = prtDataGenSparseFactors(100,1000,3,5);
    %
    %
    % Spca = train(prtPreProcSpca,DataSet);
    %
    % subplot(2,1,1)
    % stem(A)
    % title('True Factors')
    % subplot(2,1,2)
    % stem(Spca.pcaVectors)
    % title('SPCA Factors')
    
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Sparse Principal Component Analysis'
        nameAbbreviation = 'SPCA'
    end
    
    properties
        nComponents = 3;   % The number of PCA components
        
        lambda = 2000;
        nMaxIterations = 10000;
        convergenceNormPercentThreshold = 1e-3;
    end
    properties (SetAccess=private)
        means = [];           % A vector of the means
        pcaVectors = [];      % The PCA vectors.
        pcaVectorsSvd = [];
        converged = false;
    end
    
    methods
        % Allow for string, value pairs
        function Obj = prtPreProcSpca(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods
        function Obj = set.nComponents(Obj,nComp)
            if ~isnumeric(nComp) || ~isscalar(nComp) || nComp < 1 || round(nComp) ~= nComp
                error('prt:prtPreProcSpca','nComponents (%s) must be a positive scalar integer',mat2str(nComp));
            end
            Obj.nComponents = nComp;
        end
	end
    
	methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(obj) %#ok<MANU>
            featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('SPCA Score #index#');
        end
	end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)

            Obj.means = prtUtilNanMean(DataSet.getObservations(),1);
            X = bsxfun(@minus,DataSet.getObservations(),Obj.means);
            X = bsxfun(@minus,X,Obj.means);
            
            maxComponents = min(size(X));
            
            if Obj.nComponents > maxComponents
                warning('prt:prtPreProcSpca','User specified # PCA components (%d) is > number of data dimensions (%d)',Obj.nComponents,maxComponents);
                Obj.nComponents = maxComponents;
            end
            
            %Step 1, page 272
            PcaOutput = train(prtPreProcPca('nComponents',Obj.nComponents),DataSet);
            
            A = PcaOutput.pcaVectors;
            
            B = zeros(size(A));
            normDiff = zeros(1,Obj.nComponents);
            prevB = B;
            
            Obj.converged = false;
            for iter = 1:Obj.nMaxIterations
                
                %Step 2*, page 274
                for k = 1:Obj.nComponents
                    B(:,k) = softThreshold(A(:,k)'*(X'*X),Obj.lambda);
                end
                %Step 3, page 272
                [U,S,V] = svd((X'*(X*B)),'econ');
                A = U(:,1:Obj.nComponents)*V;
                
                %check convergence
                for k = 1:Obj.nComponents
                    normDiff(k) = norm(B(:,k) - prevB(:,k))./norm(B(:,k));
                end
                if all(normDiff < Obj.convergenceNormPercentThreshold)
                    Obj.converged = true;
                    break;
                end
                prevB = B;
                
                 verbosePlot = true;
                if ~mod(iter-1,verbosePlot) && verbosePlot;
                    Bplot = B;
                    for k = 1:Obj.nComponents
                        Bplot(:,k) = Bplot(:,k)./norm(Bplot(:,k));
                    end
                    plot(Bplot);
                    title(iter);
                    drawnow;
                end
                
            end
            
            %Step 5, Normalize
            for k = 1:Obj.nComponents
                B(:,k) = B(:,k)./norm(B(:,k));
            end
            Obj.pcaVectors = B;
            
            function [B,threshInd] = softThreshold(temp,lambda)
                threshInd = abs(temp) < lambda/2;  %these go to zero
                B(threshInd) = 0;
                B(~threshInd) = (abs(temp(~threshInd)) - lambda/2).*sign(temp(~threshInd));
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = DataSet.getObservations;
            X = bsxfun(@minus,X,Obj.means);
            DataSet = DataSet.setObservations(X*Obj.pcaVectors);
        end
    end
end
