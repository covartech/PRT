classdef prtDecisionBinaryMinPeWithDontCares < prtDecisionBinary
   % Similar to prtDecisionBinaryMinPe, but replace .percentDontCare data
   % points around the decision point with nan's







    properties (SetAccess = private)
        name = 'MinPeDontCares'  
        nameAbbreviation = 'min(Pe)DontCares';
    end
    properties (Hidden = true)
        threshold
        uniqueClasses
        dontCareThreshold
    end
    
    properties
        probabilityDontCare = .1;
    end
    
    methods
        
        function obj = prtDecisionBinaryMinPeWithDontCares(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        function DS = runAction(Obj,DS)
            theClasses = Obj.classList;
            Obj.dontCareThreshold
            nanInd = DS.X >= Obj.dontCareThreshold(1) & DS.X < Obj.dontCareThreshold(2);
            DS = DS.setObservations(theClasses((DS.getObservations >= Obj.getThreshold) + 1));
            DS.X(nanInd) = nan;
        end
         function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
             nanInd = xIn >= Obj.dontCareThreshold(1) & xIn < Obj.dontCareThreshold(2);
            theClasses = Obj.classList;
            xOut = theClasses((xIn >= Obj.getThreshold) + 1);
            xOut(nanInd) = nan;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinaryMinPe','prtDecisionBinaryMinPe can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            if dataSet.nClasses ~= 2
                error('prt:prtDecisionBinaryMinPe:nonBinaryData','prtDecisionBinaryMinPe expects input data to have 2 classes, but dataSet.nClasses = %d',dataSet.nClasses);
            end
            
            [pf,pd,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets);
            pe = prtUtilPfPd2Pe(pf,pd);
            [v,minPeIndex] = min(pe); %#ok<ASGLU>
            Obj.threshold = thresh(minPeIndex);

            
            nSamples = dataSet.nObservations; 
            nSamplePercent = floor(nSamples*Obj.probabilityDontCare/2);
            Obj.dontCareThreshold = [thresh(max([minPeIndex-nSamplePercent,1])),thresh(min([minPeIndex+nSamplePercent,length(thresh)]))];
            Obj.dontCareThreshold = fliplr(Obj.dontCareThreshold); %threshold is in wrong order.
            Obj.classList = dataSet.uniqueClasses;
        end
    end
    methods
        function threshold = getThreshold(Obj)
             % THRESH = getThreshold returns the objects threshold
            threshold = Obj.threshold;
        end
        function uniqueClasses = getUniqueClasses(Obj)
            uniqueClasses = Obj.uniqueClasses;
        end
    end
end
