classdef prtFeatSelGeneticAlgorithm < prtFeatSel
% prtFeatSelGeneticAlgorithm   Genetic algorithm feature selection
%
% clear all;
% close all;
% 
% f = randn(600,300);
% f(1:300,[10,292]) = f(1:300,[10,292]) + 2;
% %f(301:600,[10,292]) = f(301:600,[10,292]) + 2;
% y = prtUtilY(300,300);
% ds = prtDataSetClass(f,y);
% 
% featSelGa = prtFeatSelGeneticAlgorithm;  
% featSelGa = featSelGa.train(ds);

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
        name = 'Genetic Algorithm Feature Selection'
        nameAbbreviation = 'GAFS'
    end
    
    properties
        % General Classifier Properties
        geneEvaluationMetric = @(binaryString,ds)prtEvalAuc(prtClassFld,ds.retainFeatures(find(binaryString)));   % The metric used to evaluate performance
        
        performance = [];                 % The best performance achieved after training
        selectedFeatures = [];
        ga = prtGeneticAlgorithmBinaryString;
    end
    
    methods
        function Obj = prtFeatSelGeneticAlgorithm(varargin)
            Obj.isCrossValidateValid = false;
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        % Train %%
        function obj = trainAction(obj,ds)
            
            obj.ga.geneLength = ds.nFeatures;
            obj.ga.fitnessFunction = @(gene) obj.geneEvaluationMetric(gene,ds);
            obj.ga = obj.ga.run;
            obj.selectedFeatures = find(obj.ga.geneArray(1,:));
            obj.performance = obj.ga.currentFitnessVector(1);
            obj.isTrained = true;
        end
        
        
        % Run %
        function DataSet = runAction(Obj,DataSet) %%
            if ~Obj.isTrained
                error('prt:prtFeatSelSfs','Attempt to run a prtFeatSel that is not trained');
            end
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
    end
end
