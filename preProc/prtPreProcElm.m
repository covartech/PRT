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

% Copyright (c) 2014 CoVar Applied Technologies
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
