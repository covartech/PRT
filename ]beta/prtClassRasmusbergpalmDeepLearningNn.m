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
    
    properties (SetAccess = protected)
        nn
        nnLayerSpec = [784 100 10]; %note: last layer size MUST be equal to number of classes in data set
        nnLambda = 1e-5;
        nnAlpha = 1;
        numepochs = 100;
        batchsize = 100;
    end
    
    methods
        
        function Obj = prtClassFld(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,DataSet)
            
            prtUtilTestRasmusbergpalmPath;
            
            nnTemp = nnsetup(self.nnLayerSpec);
            
            nnTemp.lambda = self.nnLambda;      %  L2 weight decay
            nnTemp.alpha  = self.nnAlpha;       %  Learning rate
            opts.numepochs =  self.numepochs;   %  Number of full sweeps through data
            opts.batchsize = self.batchsize;    %  Take a mean gradient step over this many samples
            
            yBin = DataSet.getTargetsAsBinaryMatrix;
            self.nn = nntrain(nnTemp, DataSet.X, yBin, opts);

        end
        
        function DataSet = runAction(self,DataSet)
            
            tempY = zeros(size(DataSet.X,1),10); %need a way to figure out 10 here
            netOut = nnff(self.nn, DataSet.X, tempY);
            DataSet.X = netOut.a{end};
            
        end
        
    end
    
end