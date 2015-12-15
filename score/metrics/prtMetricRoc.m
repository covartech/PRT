classdef prtMetricRoc
    % prtMetricRoc
    %   Undocumented single-output object for prtScoreRoc
    % 
    properties
        pd
        pf
        nfa
        farDenominator
        tau
        auc
        
        thresholds = [];
    end
    
    methods
        function self = prtMetricRoc(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function h = plot(self)
            
            h = gobjects(size(self));
            for i = 1:numel(self)
                h(i) = plot(self(i).pf,self(i).pd);
                hold on;
            end
            hold off;
        end
        
        function plotRocFar(self)
            
            for i = 1:length(self)
                plot(self(i).nfa./self(i).farDenominator,self(i).pd)
                hold on;
            end
            hold off;
        end
        
    end
end