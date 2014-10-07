classdef prtPreProcDeepLearning < prtPreProc
    % prtPreProcDeepLearning  Restricted Boltzman Machine Deep Learning
    %
    % prtPreProcDeepLearning creates a RBM deep-learning object; a kind of
    %  neural network capable of learning with many different layers.
    %  Currently prtPreProcDeepLearning only uses the constrastive
    %  divergence part of the learning, and does not do additional
    %  post-processing with backpropagation.  This is to come... one day.
    %
    % Properties:
    %      layerSpecs [500 250 10] - A 1 x nLayers vector of integers
    %       specifying the number of hidden nodes at each layer.  The
    %       default specifies a 500 node layer, followed by a 250 node layer
    %       and finally a 10 node layer.
    %
    %      bootstrapSize 50 - A scalar specifying how many samples to
    %       bootstrap from each class on every learning iteration.  Best
    %       results seem to occur with small bootstrapSize and large
    %       maxIters.
    %
    %      maxIters - 1000 - A scalar specifying how many learning
    %       iterations to use for learning at each level.  Use a large
    %       number here to get reasonable results.  
    %
    % Example:
    % 
    % ds = prtDataGenMnist;
    % deep = prtPreProcDeepLearning;
    % deep = deep.train(ds);
    % plot(deep.run(ds));
    %
    % References:
    %   Hinton, Salakhutdinov, "Reducing the Dimensionality of Data with
    %   Neural Networks", Science, 2006.
    % 
    % 

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
        name = 'Deep Learning' % Principal Component Analysis
        nameAbbreviation = 'DeepLearn'  % PCA
    end
    
    properties
        layerSpecs = [500 250 12];
        bootstrapSize = 50;
        maxIters = 1000;
    end
    properties (SetAccess=private)
        layers
        w
        bi
        bj
    end
    
    methods
        
        % Allow for string, value pairs
        function self = prtPreProcDeepLearning(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
    end
    
    methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(obj) %#ok<MANU>
            featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('Deep Learning #index#');
        end
    end
    methods
        
        function dataSetUp = runActionDeconstructReconstruct(self,dataSet)
            
            dataSetDown = self.run(dataSet);
            dataSetUp = self.inverseRun(dataSetDown);
        end
        
        function dataSet = inverseRun(self,dataSetDown)
           
            X = dataSetDown.X;
            %this doesn't work for some reason... 
            for layerIndex = length(self.layerSpecs):-1:1
                
                temp = bsxfun(@plus,self.bj{layerIndex},X*self.w{layerIndex}');
                X = prtUtilLogisticSigmoid(temp);
                
            end
            dataSet = dataSetDown;
            dataSet.X = X;
        end
        
        
    end
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,dataSet)
            
            learnData = dataSet;
            h = prtUtilProgressBar(0,'','autoClose',true);
            for layerIndex = 1:length(self.layerSpecs)
                h.titleStr = sprintf('Layer %d/%d; %d Dims',layerIndex,length(self.layerSpecs),self.layerSpecs(layerIndex));
                
                [w{layerIndex},bi{layerIndex},bj{layerIndex}] = learnRbm(self,learnData,layerIndex);
                
                visibleSigTerm = bsxfun(@plus,bi{layerIndex},learnData.getX*w{layerIndex});
                pVisible = prtUtilLogisticSigmoid(visibleSigTerm);
                learnData.X = pVisible; %next iteration, learn with this
                h.update(layerIndex/length(self.layerSpecs));
            end
            self.w = w;
            self.bi = bi;
            self.bj = bj;
            
            %To do: add in back-propagation here(!)
        end
        
        function dataSet = runAction(self,dataSet)
            
            learnData = dataSet;
            for layerInd = 1:length(self.w)
                visibleSigTerm = bsxfun(@plus,self.bi{layerInd},learnData.getX*self.w{layerInd});
                pVisible = prtUtilLogisticSigmoid(visibleSigTerm);
                learnData.X = pVisible;
            end
            dataSet.X = visibleSigTerm;
        end
        
        function [w,bi,bj,xOut] = learnRbm(self,dataSet,currentLayer)
            %w = learnRbm(data,nUnits)
            
            % To do:
            %   Include gradient momentum
            %   Include weight penalties 
            
            nUnits = self.layerSpecs(currentLayer);
            isLastLayer = currentLayer == length(self.layerSpecs);
            
            nFeatures = dataSet.nFeatures;
            w = randn(nFeatures,nUnits)/10;
            bi = zeros(1,nUnits)/10;
            bj = zeros(1,nFeatures)/10;
            
            step = .1;
            if isLastLayer
                %Much more sensitive in real data; why?  who knows
                step = 0.001;
            end
            
            gradW = zeros(size(w));
            gradBi = zeros(size(bi));
            gradBj = zeros(size(bj));
            
            %Momenta, and weight logic are all taken from the supplemental
            %material from the Hinton Science article.  They aren't
            %parameters yet.  They also seem pretty "hacky".
            momentum = .5;
            finalMomentum = .9;
            weightCost = .0004;
            
            h = prtUtilProgressBar(0,'Learning...','autoClose',true);
            modelErr = nan(1,self.maxIters);
            for iterInd = 1:self.maxIters
                if iterInd > self.maxIters/2
                    momentum = finalMomentum;
                end
                
                
                temp = dataSet.bootstrapByClass(self.bootstrapSize);
                data = temp.getX;
                
                %                 [vishid,hidbiases,visbiases] = rbmStep(data,w,bi,bj);
                
                nObs = size(data,1);
                
                visibleSigTerm = bsxfun(@plus,bi,data*w);
                if isLastLayer
                    pVisible = visibleSigTerm;
                    hiddenGen = visibleSigTerm + randn(size(visibleSigTerm));
                else
                    pVisible = prtUtilLogisticSigmoid(visibleSigTerm);
                    hiddenGen = double(rand(size(pVisible)) < pVisible);
                end
                
                hiddenSigTerm = bsxfun(@plus,bj,hiddenGen*w');
                
                if isLastLayer 
                    vConfab = prtUtilLogisticSigmoid(hiddenSigTerm);
                    pConfab = bsxfun(@plus,bi,vConfab*w);
                else
                    vConfab = prtUtilLogisticSigmoid(hiddenSigTerm);
                    pConfab = bsxfun(@plus,bi,vConfab*w);
                    pConfab = prtUtilLogisticSigmoid(pConfab);
                end
                
                
                modelErr(iterInd) = sum(sum( (data-vConfab).^2 ));
                if ~mod(iterInd,10)
                    h.update(iterInd/self.maxIters);
                    %                     subplot(2,2,1:2); stem(modelErr);
                    %                     subplot(2,2,3); imagesc(w); % subplot(2,2,4); imagesc(vishid);
                    drawnow;
                end
                
                % Simple:
                %                 wgrad = (data'*pVisible - vConfab'*pConfab);
                %                 wgrad = wgrad./nObs;
                %
                %                 bjgrad = sum(data)-sum(vConfab);
                %                 bjgrad = bjgrad./nObs;
                %
                %                 bigrad = sum(pVisible)-sum(pConfab);
                %                 bigrad = bigrad./nObs;
                %
                %                 w = w + wgrad*step;
                %                 bi = bi + bigrad*step;
                %                 bj = bj + bjgrad*step;
                
                % With momentum... 
                wgradCurrent = (data'*pVisible - vConfab'*pConfab);
                wgradCurrent = wgradCurrent./nObs;
                gradW = momentum*gradW + step*(wgradCurrent - weightCost*w);
                
                bjgradCurrent = sum(data)-sum(vConfab);
                bjgradCurrent = bjgradCurrent./nObs;
                gradBj = momentum*gradBj + step*(bjgradCurrent);
                
                bigradCurrent = sum(pVisible)-sum(pConfab);
                bigradCurrent = bigradCurrent./nObs;
                gradBi = momentum*gradBi + step*(bigradCurrent);
                
                w = w + gradW; 
                bi = bi + gradBi;
                bj = bj + gradBj;
            end
            h.update(1);
            xOut = prtUtilLogisticSigmoid(bsxfun(@plus,bi,data*w));
        end
        
    end
end
