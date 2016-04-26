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
        ga = prtUtilGeneticAlgorithmBinaryString;
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
