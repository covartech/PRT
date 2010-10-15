classdef prtFeatSelGeneticAlgorithm < prtFeatSel
% prtFeatSelGeneticAlgorithm   Genetic algorithm feature selection
%
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Genetic Algorithm Feature Selection'
        nameAbbreviation = 'GAFS'
        isSupervised = true;
    end
    
    properties
        % General Classifier Properties
        showProgressBar = true;           % Whether or not the progress bar should be displayed
        geneEvaluationMetric = @(binaryString,ds)prtEvalAuc(prtClassFld,ds.retainFeatures(find(binaryString)));   % The metric used to evaluate performance
        
        performance = [];                 % The best performance achieved after training
        selectedFeatures = [];
        ga = prtGeneticAlgorithmBinaryString;
    end
    
    methods
        
        
        % Constructor %%
        
        % Allow for string, value pairs
        function Obj = prtFeatSelGeneticAlgorithm(varargin)
            Obj.isCrossValidateValid = false;
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
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
