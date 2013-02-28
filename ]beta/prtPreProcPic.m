classdef prtPreProcPic < prtPreProc
    % PIC - Power Iteration Clustering
    % Although we use the acronym this does not do the clustering
    % It extracts a good direction for (spectral) clustering based on the
    % kernel and the resulting similarity matrix.
    %
    % This is currently broken for cross-validation. Not sure how to do the
    % run. I attempt to keep track of normalization values I thought this
    % would work but it didn't. The paper doesn't explain how to do it.
    % Technically I don't think you are supposed to ...
    %
    % Lin and Cohen, 2010, ICML, Power Iteration Clustering
    %
    % Example
    %   ds = prtDataGenCircles;
    %   output = kfolds(prtPreProcPic('kernel',prtKernelRbf('sigma',0.1)) + prtClusterKmeans('nClusters',2) + prtDecisionMap,ds,1);
    %   dsLearnedTargets = ds;
    %   dsLearnedTargets = dsLearnedTargets.setTargets(output.getObservations);
    %   subplot(1,2,1)
    %   plot(ds), title('Input Data');
    %   subplot(1,2,2)
    %   plot(dsLearnedTargets), title('Learned Clustering');

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


    properties (SetAccess=private)
        % Required by prtAction
        name = 'Power Iteration Clustering'
        nameAbbreviation = 'PIC'
    end
    
    properties
        nFeatures = 1; % This is probably what you want
        nMaxIterations = 100; % PI converges very fast, you probably wont need more
        kernel = prtKernelRbfNdimensionScale;
        tolerancePerDimension = 1e-5; % Suggested in the paper
        
        normalizationFactors = [];
        
        V = []; % Projection Directions, learned
    end
    methods
        
        function Obj = prtPreProcPic(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = preTrainProcessing(Obj,DataSet)
            if ~Obj.verboseStorage
                warning('prtPreProcPic:verboseStorage:false','prtPreProcPic requires verboseStorage to be true; overriding manual settings');
            end
            Obj.verboseStorage = true;
            Obj = preTrainProcessing@prtPreProc(Obj,DataSet);
        end
        
        function Obj = trainAction(Obj,ds)
            
            W = prtKernel.evaluateMultiKernelGram({Obj.kernel},ds,ds);
            W = W .* (1-eye(size(W)));
            
            Obj.normalizationFactors = sum(W,2);
            
            % Initial v
            if Obj.nFeatures == 1
                % If we want only one feature we use the good initialization scheme
                % suggested in the paper
                v = Obj.normalizationFactors;
                v = v./sum(v);
                % else we do it randomly below
            end
            
            % Row Sum Normalize W
            % We can't do this before we initialize v
            W = bsxfun(@rdivide,W,Obj.normalizationFactors);
            
            % A place to store all of the v's
            Obj.V = zeros(size(v),Obj.nFeatures);
            
            % For each
            nSamples = size(W,1);
            for iFeature = 1:Obj.nFeatures
                
                if Obj.nFeatures > 1
                    % If we want more than one feature we use random initializations
                    v = randn(size(W,1),1);
                    v = v./sum(v);
                end
                
                % Initialize delta (assumes first set of weights was all zeros)
                delta = abs(v);
                
                % Power iteration
                for iter = 2:Obj.nMaxIterations
                    prevV = v;
                    prevDelta = delta;
                    
                    cTempProd = W*v;
                    v = cTempProd/norm(cTempProd,1);
                    
                    delta = abs(v-prevV);
                    
                    eta = max(abs(delta-prevDelta));
                    if eta < Obj.tolerancePerDimension/nSamples
                        % Done
                        break
                    end
                end
                
                % Store this component
                Obj.V(:,iFeature) = v;
            end
        end
        
        function Output = runAction(Obj,Input)
            
            W = prtKernel.evaluateMultiKernelGram({Obj.kernel},Obj.DataSet,Input);
            W = W .* (1-eye(size(W)));
            W = bsxfun(@rdivide,W,Obj.normalizationFactors);
            
            Output = prtDataSetClass(W*Obj.V);
        end
    end
end
    



