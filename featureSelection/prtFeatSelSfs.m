%
classdef prtFeatSelSfs < prtFeatSel %
    
    properties (SetAccess=private) 
        % Required by prtAction
        name = 'Sequentual Feature Selection'
        nameAbbreviation = 'SFS'
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
        
        function Obj = prtFeatSelSfs(varargin) 
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        
    end
    methods (Access = protected)
        
        % Train %%
        
        function Obj = trainAction(Obj,DS) 
            
            nFeatsTotal = DS.nFeatures;
            
            sfsPerformance = zeros(min(nFeatsTotal,Obj.nFeatures),1);
            sfsSelectedFeatures = [];
            
            canceled = false;
            for j = 1:min(nFeatsTotal,Obj.nFeatures);
                
                if Obj.showProgressBar
                    h = prtUtilWaitbarWithCancel('SFS');
                end
                
                availableFeatures = setdiff(1:nFeatsTotal,sfsSelectedFeatures);
                performance = nan(size(availableFeatures));
                for i = 1:length(availableFeatures)
                    currentFeatureSet = cat(2,sfsSelectedFeatures,availableFeatures(i));
                    tempDataSet = DS.retainFeatures(currentFeatureSet);
                    performance(i) = Obj.EvaluationMetric(tempDataSet);
                    
                    if Obj.showProgressBar
                        prtUtilWaitbarWithCancel(i/length(availableFeatures),h);
                    end
                    
                    if ~ishandle(h)
                        canceled = true;
                        break
                    end
                end
                
                if Obj.showProgressBar && ~canceled
                    close(h);
                end
                
                if canceled
                    break
                end
                
                % Randomly choose the next feature if more than one provide the same performance
                [val,newFeatInd] = max(performance);
                newFeatInd = find(performance == val);
                newFeatInd = newFeatInd(max(1,ceil(rand*length(newFeatInd))));
                % In the (degenerate) case when rand==0, set the index to the first one
                
                sfsPerformance(j) = val;
                sfsSelectedFeatures(j) = [availableFeatures(newFeatInd)];
            end
            Obj.performance = sfsPerformance;
            Obj.selectedFeatures = sfsSelectedFeatures;
        end
        
        
        
        % Run %
                
        function DataSet = runAction(Obj,DataSet) %%
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
        
        
    end
    
    
end
