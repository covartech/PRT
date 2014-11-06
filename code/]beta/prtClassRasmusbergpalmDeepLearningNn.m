classdef prtClassRasmusbergpalmDeepLearningNn < prtClass
 %prtClassRasmusbergpalmDeepLearningNn Fisher linear discriminant classifier
 % 
 % ds = prtDataGenMnist;
 % nn = prtClassRasmusbergpalmDeepLearningNn + prtDecisionMap;
 % yOut = nn.kfolds(ds,2);

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
        name = 'Deep Learning NN'
        nameAbbreviation = 'DLNN'
        isNativeMary = true;
    end
    
    properties 
        nn
        nnLayerSpec = [100 10]; %note: first & last layers are assumed to be nFeatures and nClasses respectively; these values specify the sizes of the hidden layers
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
        
        function self = trainAction(self,dataSet)
            
            prtUtilTestRasmusbergpalmPath;
            
            fullSpec = cat(2,dataSet.nFeatures,self.nnLayerSpec,dataSet.nClasses);
            nnTemp = nnsetup(fullSpec);
            
            nnTemp.lambda = self.nnLambda;      %  L2 weight decay
            nnTemp.alpha  = self.nnAlpha;       %  Learning rate
            opts.numepochs =  self.numepochs;   %  Number of full sweeps through data
            opts.batchsize = self.batchsize;    %  Take a mean gradient step over this many samples
            
            yBin = dataSet.getTargetsAsBinaryMatrix;
            self.nn = nntrain(nnTemp, dataSet.X, yBin, opts);
        end
        
        function dataSet = runAction(self,dataSet)
            
            tempY = zeros(size(dataSet.X,1),size(self.nn.b{end},1));
            netOut = nnff(self.nn, dataSet.X, tempY);
            dataSet.X = netOut.a{end};
            
        end
        
    end
    
end
