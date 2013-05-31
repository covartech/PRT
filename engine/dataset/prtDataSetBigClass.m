classdef prtDataSetBigClass < prtDataSetBig
    % prtDataSetBigClass is a class for prtDataSetBig that are for
    % classification. It is currently a placeholder for future
    % classification specific helper methods.
    
    methods
        function self = prtDataSetBigClass(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
        function summary = summarize(self)
            if isempty(self.summaryCache)
                mrSummary = prtMapReduceSummarizeDataSetClass;
                self.summaryCache = mrSummary.run(self);
            end
            summary = self.summaryCache;
        end
        function plot(self)
            plot(self.getRandomBlock())
        end
    end
end