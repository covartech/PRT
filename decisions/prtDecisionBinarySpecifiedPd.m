classdef prtDecisionBinarySpecifiedPd < prtDecisionBinary
    % xxx NEED HELP xxx
    %
    % prtDecisionBinarySpecifiedPd prt Decision action to find a threshold in a
    % binary problem to approximately acheive a specified probability of
    % detection
    %
    
    properties (SetAccess = private)
        name = 'SpecifiedPd'
        nameAbbreviation = 'SpecPd';
        isSupervised = true;
    end
    properties
        pd
    end
    properties (Hidden = true)
        threshold
        uniqueClasses
    end
    methods
        function obj = set.pd(obj,value)
            assert(isscalar(value) && value >= 0 && value <= 1,'d parameter must be scalar in [0,1], value provided is %s',mat2str(value));
            obj.pd = value;
        end
    end
    methods
        function obj = prtDecisionBinarySpecifiedPd(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
    end
    methods (Access = protected)
        
        
        function Obj = trainAction(Obj,dataSet)
            
            if dataSet.nFeatures > 1
                error('prt:prtDecisionBinaryMinPe','prtDecisionBinaryMinPe can not be used on algorithms that output multi-column results; consider using prtDecisionMap instead');
            end
            [rocPf,rocPd,thresh] = prtScoreRoc(dataSet.getObservations,dataSet.getTargets); %#ok<ASGLU>
            thresh = thresh(:);
            %thresh = cat(1,min(thresh)-eps(min(thresh)),thresh);
            index = find(rocPd >= Obj.pd,1);
            Obj.threshold = thresh(index);
            disp(Obj.threshold)
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