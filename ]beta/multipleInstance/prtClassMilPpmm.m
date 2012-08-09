classdef prtClassMilPpmm < prtClass
    
    properties (SetAccess=private)
        
        name = 'PPMM' % Fisher Linear Discriminant
        nameAbbreviation = 'PPMM'            % FLD
        isNativeMary = false;  % False
    end
    properties
        
        svm = prtClassSvm;
        numMeans = 30;
        numOptimKmeans = 500;
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
            
            disp('train');
            if ~self.numOptimKmeans
                [self.clusterMeans,clusterIndex] = prtUtilKmeans(x,self.numMeans);
                
                for i = 1:length(uBagInds)
                    p(i,:) = hist(clusterIndex(bagInds == uBagInds(i)),1:self.numMeans);
                end
                p = bsxfun(@rdivide,p,sum(p,2));
                
                dsP = prtDataSetClass(p,dataSetMil.targets);
                self.svm.kernels = prtKernelPpmm;
                self.svm.c = 1;
                self.svm = self.svm.train(dsP);
            else
                disp('here');
                
                for i = 1:self.numOptimKmeans
                    [self.clusterMeans,clusterIndex] = prtUtilKmeans(x,self.numMeans);
                    kmeans{i}= self.clusterMeans;
                    indices{i} = clusterIndex';
                    
                    for j = 1:length(uBagInds)
                        p(j,:) = hist(clusterIndex(bagInds == uBagInds(j)),1:self.numMeans);
                    end
                    p = bsxfun(@rdivide,p,sum(p,2));
                    
                    dsP = prtDataSetClass(p,dataSetMil.targets);
                    self.svm.kernels = prtKernelPpmm;
                    self.svm.c = 1;
                    self.svm = self.svm.train(dsP);
                    yOut = self.svm.run(dsP);
                    pc(i) = prtScorePercentCorrect(rt(prtDecisionBinaryMinPe,yOut));
                    disp([i, max(pc)]);
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
                self.svm.kernels = prtKernelPpmm;
                self.svm.c = 1;
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