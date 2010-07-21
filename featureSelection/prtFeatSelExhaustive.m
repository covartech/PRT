classdef prtFeatSelExhaustive < prtFeatSel %
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Exhaustive Feature Selection'
        nameAbbreviation = 'Efs'
        isSupervised = true;
    end
    
    properties
        % General Classifier Properties
        nFeatures = 3;
        showProgressBar = true;
        EvaluationMetric = @(DS)prtScoreAuc(DS,prtClassFld);
        
        performance = [];
        selectedFeatures = [];
    end
    
    
    
    methods
        
        % Constructor %%
        
        function Obj = prtFeatSelExhaustive(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    methods (Access = protected)
        
        % Train %%
        
        function Obj = trainAction(Obj,DS)
            
            bestPerformance = -inf;
            bestChoose = [];
            
            Obj.nFeatures = min(DS.nFeatures,Obj.nFeatures);
            %warning off;
            maxIterations = nchoosek(DS.nFeatures,Obj.nFeatures);
            %warning on;
            
            iterationCount = 1;
            nextChooseFn = prtNextChoose(DS.nFeatures,Obj.nFeatures);
            firstChoose = nextChooseFn();
            currChoose = firstChoose;
            
            finishedFunction = @(current) isequal(current,firstChoose);
            
            if Obj.showProgressBar
                h = prtUtilWaitbarWithCancel('Exhaustive Feature Selection');
            end
            
            notFinished = true;
            canceled = false;
            while notFinished;
                if Obj.showProgressBar
                    prtUtilWaitbarWithCancel(iterationCount/maxIterations,h);
                end
                
                tempDataSet = DS.retainFeatures(currChoose);
                currPerformance = Obj.EvaluationMetric(tempDataSet);
                
                if any(currPerformance > bestPerformance) || isempty(bestChoose)
                    bestChoose = currChoose;
                    bestPerformance = currPerformance;
                elseif currPerformance == bestPerformance
                    bestChoose = cat(1,bestChoose,currChoose);
                    bestPerformance = cat(1,bestPerformance,currPerformance);
                end
                currChoose = nextChooseFn();
                notFinished = ~finishedFunction(currChoose);
                iterationCount = iterationCount + 1;
                
                if ~ishandle(h)
                    canceled = true;
                    break
                end
            end
            
            if Obj.showProgressBar && ~canceled
                delete(h);
            end
            drawnow;
            
            if size(bestChoose,1) > 1
                warning('prt:exaustiveSetsTie','Multiple identical performing feature sets found with performance %f; randomly selecting one feature set for output',bestPerformance(1));
                index = max(ceil(rand*size(bestChoose,1)),1);
                bestChoose = bestChoose(index,:);
                bestPerformance = bestPerformance(index,:);
            end
            
            Obj.performance = bestPerformance;
            Obj.selectedFeatures = bestChoose;
        end
        
        
        
        % Run %
        
        function DataSet = runAction(Obj,DataSet) %%
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
        
        
    end
    
    
end
