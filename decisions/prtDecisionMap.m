classdef prtDecisionMap < prtDecision
    % Maximum a-posteriori decision making
    %
    % Basically takes the max over the column outputs.
     properties (SetAccess = private)
        name = 'MAP'
        nameAbbreviation = 'MAP';
        isSupervised = false;
    end
    
    methods
        function Obj = prtDecisionMap(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    methods (Access = protected)
        
        function Obj = trainAction(Obj, DS)
            Obj.classList = DS.uniqueClasses;
        end
        function DS = runAction(Obj,DS)
            yOut = DS.getObservations;
            if size(yOut,2) > 1
                [~,index] = max(yOut,[],2);
            else
                error('prt:prtDecisionMap','Cannot run prtDecisionMap on algorithms with single-column output; use prtDecisionBinaryMinPe instead');
            end
            classList = Obj.classList(index);
            classList = classList(:);
            DS = DS.setObservations(classList);
        end
    end
end