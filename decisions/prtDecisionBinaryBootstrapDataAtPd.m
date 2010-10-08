classdef prtDecisionBinaryBootstrapDataAtPd < prtDecisionBinary
    properties (SetAccess = private)
        name = 'BootstrapDataAtPd'
        nameAbbreviation = 'BSDPD';
        isSupervised = true;
    end
    
    properties
        pd = 1;
        nFolds
        confidence = 0.95;
        nBootStrapSamples = [];
        ThresholdSetSummary
        
        algorithm
        threshold
    end
    
    methods
        function Obj = prtDecisionBinaryBootstrapDataAtPd(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function threshold = getThreshold(Obj)
            threshold = Obj.threshold;
        end
    end
    methods (Access = protected)
        function Obj = trainAction(Obj, DS)
            
            if isempty(Obj.nBootStrapSamples)
                Obj.nBootStrapSamples = DS.nObservations;
            end
            
            badIterations = false(Obj.nBootStrapSamples,1);
            pfAtPd1 = zeros(Obj.nBootStrapSamples,1);
            thresholdAtPd1 = zeros(Obj.nBootStrapSamples,1);
            for iBootStrap = 1:Obj.nBootStrapSamples
                [cDSBoot cSampleInds] = DS.bootstrap(Obj.nBootStrapSamples);
                
                try
                    algorithmOutput = Obj.algorithm.kfolds(cDSBoot,Obj.nFolds);
        
                    [pf,pd,auc,thresholds] = prtScoreRoc(algorithmOutput.getObservations(),cDSBoot.getTargets());
            
                    [pfAtPd1(iBootStrap), thresholdAtPd1(iBootStrap)] = prtUtilPfAtPd1(pf,pd,thresholds);
                catch
                    badIterations(iBootStrap) = true;
                    pfAtPd1(iBootStrap) = nan;
                    thresholdAtPd1(iBootStrap) = nan;
                end
            end
        
            Obj.algorithm = Obj.algorithm.train(DS);
            algorithmOutput = Obj.algorithm.run(DS);
            algorithmOutput = algorithmOutput.setTargets(DS.getTargets);
            sortedH0Data = sort(algorithmOutput.getObservationsByClassInd(1),'ascend');
            
            [sortedPfAtPd1, sortingInds] = sort(pfAtPd1,'ascend');
            
            sortedPfAtPd1Ind = max(min(round(Obj.confidence*length(sortedPfAtPd1)),length(sortedPfAtPd1)),1);
            thresholdInd = max(min(round((1-sortedPfAtPd1(sortedPfAtPd1Ind))*length(sortedH0Data)),length(sortedH0Data)),1);
            
            Obj.threshold = sortedH0Data(thresholdInd);
            Obj.ThresholdSetSummary.pfAtPd1 = pfAtPd1;
            Obj.classList = DS.uniqueClasses;
        end
        function DS = runAction(Obj,DS)
            algorithmOutput = Obj.algorithm.run(DS);
            DS = DS.setObservations((algorithmOutput.getObservations > Obj.getThreshold) + 1);
        end
    end
end