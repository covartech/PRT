classdef prtDataSetBigClass < prtDataSetBig & prtDataInterfaceCategoricalTargetsBig
    % prtDataSetBigClass is a class for prtDataSetBig that are for
    % classification. It is currently a placeholder for future
    % classification specific helper methods.
    
    properties (Hidden) %for users:
        %         nClasses
        %         uniqueClasses
        %         isMary
        nFeatures
        %nObservations
        %nTargetDimensions
    end
    
    properties (Hidden)
        nClassesStaticHelper
        uniqueClassesStaticHelper
    end
    
    
    methods (Hidden)
            
        function self = summaryClear(self)
            % self = summaryClear(self)
            self.summaryCache = [];
            self.targetCacheInitialized = false;
        end
        
        function self = summaryBuild(self,force)
            % self = summaryBuild(self,force)
            % 
            if nargin < 2
                force = false;
            end
            if force || isempty(self.summaryCache)
                mrSummary = prtMapReduceSummarizeDataSetClass;
                self.summaryCache = mrSummary.run(self);
                self.targetCache = self.summaryCache.targetCache;
                self.classNames = self.targetCache.classNames;
                self.targetCacheInitialized = true;
            end
        end
    end
    
    methods
        
        function self = prtDataSetBigClass(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
        
        function n = get.nFeatures(self)
            summary = self.summarize;
            n = summary.nFeatures;
        end
        
        function n = getNumObservations(self)
            summary = self.summarize;
            n = summary.nObservations;
        end
        
        function n = getNumTargetDimensions(self)
            summary = self.summarize;
            n = summary.nTargetDimensions;
        end
        
        function summary = summarize(self)
            summary = self.summaryCache;
            if isempty(summary)
                error('prtDataSetBig:summaryNotBuild','The data set big object does not have a valid summary; use ds = ds.summaryBuild to build and cache one');
            end
        end
        
        function plot(self)
            plot(self.getRandomBlock())
        end
    end
end