classdef prtClassMilPpmmRbf < prtClass
    % prtClassMilPpmmRbf; prtClassMilPpmm but with RBF kernels





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
        function Obj = prtClassMilPpmmRbf(varargin)
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
