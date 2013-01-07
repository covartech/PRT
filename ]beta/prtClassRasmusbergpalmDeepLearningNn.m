classdef prtClassRasmusbergpalmDeepLearningNn < prtClass
 %prtClassRasmusbergpalmDeepLearningNn Fisher linear discriminant classifier
 % 
 % ds = prtDataGenMnist;
 % nn = prtClassRasmusbergpalmDeepLearningNn + prtDecisionMap;
 % yOut = nn.kfolds(ds,2);
 

    properties (SetAccess=private)
        
        name = 'Deep Learning NN'
        nameAbbreviation = 'DLNN'
        isNativeMary = true;
    end
    
    properties
        nn
        nnLayerSpec = 100;
        nnLambda = 1e-5;
        nnAlpha = 1;
        numepochs = 100;
        batchsize = 100;
    end
    
    methods
        
        function Obj = prtClassRasmusbergpalmDeepLearningNn(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,DataSet)
            
            prtUtilTestRasmusbergpalmPath;
            
            nnLayers = [DataSet.nFeatures self.nnLambda DataSet.nClasses];
            nnTemp = nnsetup(nnLayers);
            
            nnTemp.lambda = self.nnLambda;     %  L2 weight decay
            nnTemp.alpha  = self.nnAlpha;       %  Learning rate
            opts.numepochs =  self.numepochs;   %  Number of full sweeps through data
            opts.batchsize = self.batchsize;    %  Take a mean gradient step over this many samples
            
            yBin = DataSet.getTargetsAsBinaryMatrix;
            self.nn = nntrain(nnTemp, DataSet.X, yBin, opts);

        end
        
        function DataSet = runAction(self,DataSet)
            
            tempY = zeros(size(DataSet.X,1),self.dataSetSummary.nClasses); %need a way to figure out 10 here
            netOut = nnff(self.nn, DataSet.X, tempY);
            DataSet.X = netOut.a{end};
            
        end
        
    end
    
end