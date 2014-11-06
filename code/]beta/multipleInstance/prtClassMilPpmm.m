classdef prtClassMilPpmm < prtClass

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
        
        name = 'PPMM' % Fisher Linear Discriminant
        nameAbbreviation = 'PPMM'            % FLD
        isNativeMary = false;  % False
    end
    properties
        
        optimSvmCost = false;
        svm = prtClassLibSvm;
        numMeans = 30;
        numOptimKmeans = 50;
    end
    properties (SetAccess = protected)
        clusterMeans = [];
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtClassMilPpmm(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.classTrain = 'prtDataSetClassMultipleInstance';
            Obj.classRun = 'prtDataSetClassMultipleInstance';
            Obj.classRunRetained = false;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSetMil)
            
            x = dataSetMil.expandedData;
            bagInds = dataSetMil.getBagInds;
            uBagInds = unique(bagInds);
            
            if ~self.numOptimKmeans
                [self.clusterMeans,clusterIndex] = prtUtilKmeans(x,self.numMeans);
                
                for i = 1:length(uBagInds)
                    p(i,:) = hist(clusterIndex(bagInds == uBagInds(i)),1:self.numMeans);
                end
                p = bsxfun(@rdivide,p,sum(p,2));
                
                dsP = prtDataSetClass(p,dataSetMil.targets);
                self.svm.kernelType = 4;
                self.svm.userSpecKernel = prtKernelPpmm;
                
                %Get best cost
                if self.optimSvmCost
                    self.svm = self.svm.optimize(dsP, @(class,ds)prtEvalAuc(class,ds,3), 'cost', logspace(-2,2,10));
                end
                %Get corresponding best classifier
                self.svm = self.svm.train(dsP);
                %Get best score
                %yOut = self.svm.run(dsP);
                
            else
                
                fprintf('Optimizing over %d k-means\n',self.numOptimKmeans);
                for i = 1:self.numOptimKmeans
                    [self.clusterMeans,clusterIndex] = prtUtilKmeans(x,self.numMeans);
                    kmeans{i}= self.clusterMeans;
                    indices{i} = clusterIndex';
                    
                    for j = 1:length(uBagInds)
                        p(j,:) = hist(clusterIndex(bagInds == uBagInds(j)),1:self.numMeans);
                    end
                    p = bsxfun(@rdivide,p,sum(p,2));
                    
                    dsP = prtDataSetClass(p,dataSetMil.targets);
                    self.svm.kernelType = 4;
                    self.svm.userSpecKernel = prtKernelPpmm;
                    self.svm.cost = 1;
                    
                    %Get best cost
                    if self.optimSvmCost
                        self.svm = self.svm.optimize(dsP, @(class,ds)prtEvalAuc(class,ds,3), 'cost', logspace(-2,2,10));
                    end
                    %Get corresponding best classifier
                    self.svm = self.svm.train(dsP);
                    %Get best score
                    yOut = self.svm.run(dsP);
                    
                    pc(i) = prtScorePercentCorrect(rt(prtDecisionBinaryMinPe,yOut));
                    drawnow;
                end
                
                [~,clusterMaxIndex] = max(pc);
                self.clusterMeans = kmeans{clusterMaxIndex};
                clusterIndex = indices{clusterMaxIndex}';
                
                for j = 1:length(uBagInds)
                    p(j,:) = hist(clusterIndex(bagInds == uBagInds(j)),1:self.numMeans);
                end
                p = bsxfun(@rdivide,p,sum(p,2));
                
                dsP = prtDataSetClass(p,dataSetMil.targets);
                self.svm.kernelType = 4;
                self.svm.userSpecKernel = prtKernelPpmm;
                self.svm.cost = 1;
                self.svm = self.svm.train(dsP);
                
            end
                
        end
        
        function yOut = runAction(self,dataSetMil)
            
            x = dataSetMil.expandedData;
            bagInds = dataSetMil.getBagInds;
            uBagInds = unique(bagInds);
            
            clusterDist = prtDistanceEuclidean(self.clusterMeans,x);
            
            [~,clusterIndex] = min(clusterDist,[],1);
            for i = 1:length(uBagInds)
                p(i,:) = hist(clusterIndex(bagInds == uBagInds(i)),1:self.numMeans);
            end
            p = bsxfun(@rdivide,p,sum(p,2));
            
            dsP = prtDataSetClass(p,dataSetMil.targets);
            yOut = self.svm.run(dsP);
        end
    end
    
end
