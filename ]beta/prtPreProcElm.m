classdef prtPreProcElm < prtPreProc
    %prtPreProcElm - Extreme Learning Machine
    %   A 1 Hidden Layer Neural Network with Random Weights
    %
    % Example:
    %    dsTrain = prtDataGenXor;
    %    dsTest = prtDataGenXor;
    %    algo = prtPreProcElm('nNeurons',1000) + prtClassLr;
    %    algo = algo.train(dsTrain);
    %    yOut = algo.run(dsTest);
    %    close all;
    %    prtScoreRoc(yOut);
    
    
    properties (SetAccess=private)
        name = 'Extreme Learning Machine'
        nameAbbreviation = 'ELM' 
    end
    
    properties (SetAccess = protected)
        
    end
    
    properties
        nNeurons = 100;
        activationFunction = @(x)1./(1 + exp(-x));
        
        weights = [];
        bias = []
    end
    
    methods
     
               % Allow for string, value pairs
        function self = prtPreProcElm(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            self.weights = rand(dataSet.nFeatures, self.nNeurons)*2 - 1;
            self.bias = rand(1,self.nNeurons);
        end
        
        function dataSet = runAction(self,dataSet)
           dataSet.X = self.activationFunction(bsxfun(@plus, dataSet.X*self.weights, self.bias));
        end
    end
end
