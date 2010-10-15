classdef prtDecisionBinarySpecifiedPf < prtDecisionBinary
    % xxx NEED HELP xxx
    %
    % prtDecisionBinarySpecifiedPf prt Decision action to find a threshold in a
    % binary problem to approximately acheive a specified probability of
    % false alarm
    %
    
    properties (SetAccess = private)
        name = 'SpecifiedPf'
        nameAbbreviation = 'SpecPf';
        isSupervised = true;
    end
    properties
        pf
    end
    properties (Hidden = true)
        threshold
        uniqueClasses
    end
    methods
        function obj = set.pf(obj,value)
            assert(isscalar(value) && value >= 0 && value <= 1,'d parameter must be scalar in [0,1], value provided is %s',mat2str(value));
            obj.pf = value;
        end
    end
    methods
        function obj = prtDecisionBinarySpecifiedPf(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    methods (Access = protected)
        
        
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinaryMinPe','prtDecisionBinaryMinPe can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            [pf,pd,auc,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets);
            
            index = find(pf < Obj.pf,1);
            Obj.threshold = thresh(index);
            Obj.classList = dataSet.uniqueClasses;
        end
    end
    methods
        function threshold = getThreshold(Obj)
            threshold = Obj.threshold;
        end
        function uniqueClasses = getUniqueClasses(Obj)
            uniqueClasses = Obj.uniqueClasses;
        end
    end
end