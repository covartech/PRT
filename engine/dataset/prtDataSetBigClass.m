classdef prtDataSetBigClass < prtDataSetBig
    % prtDataSetBigClass is a class for prtDataSetBig that are for
    % classification. It is currently a placeholder for future
    % classification specific helper methods.
    
    properties (Hidden) %for users:
        nClasses
        uniqueClasses
        isMary
        nFeatures
        nObservations
        nTargetDimensions
    end
    
    properties (Hidden)
        nClassesStaticHelper
        uniqueClassesStaticHelper
    end
    
    methods
        
        function self = prtDataSetBigClass(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
        
        function is = get.isMary(self)
            summary = self.summarize;
            is = summary.isMary;
        end
        
        function n = get.nFeatures(self)
            summary = self.summarize;
            n = summary.nFeatures;
        end
        
        function n = get.nObservations(self)
            summary = self.summarize;
            n = summary.nObservations;
        end
        
        function n = get.nTargetDimensions(self)
            summary = self.summarize;
            n = summary.nTargetDimensions;
        end
        
        function n = get.nClasses(self)
            if isempty(self.nClassesStaticHelper)
                summary = self.summarize;
                self.nClassesStaticHelper = summary.nClasses;
            end
            n = self.nClassesStaticHelper;
        end
        
        function n = get.uniqueClasses(self)
            if isempty(self.uniqueClassesStaticHelper)
                summary = self.summarize;
                self.uniqueClassesStaticHelper = summary.uniqueClasses;
            end
            n = self.uniqueClassesStaticHelper;
        end
        
        function [summary,self] = summarize(self)
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