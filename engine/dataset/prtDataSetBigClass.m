classdef prtDataSetBigClass < prtDataSetBig & prtDataInterfaceCategoricalTargetsBig
    % prtDataSetBigClass is a class for prtDataSetBig that are for
    % classification. It is currently a placeholder for future
    % classification specific helper methods.
        
    
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
        
        function n = getNumFeatures(self)
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
                summary = getDefaultSummaryStruct(self);
            end
        end
        
        function varargout = plot(self)
            plotHandles = plot(self.getRandomBlock());
            varargout = {};
            if nargout
                varargout = {plotHandles};
            end
        end
    end
    methods (Hidden)
        function summary = getDefaultSummaryStruct(self)
            
            warning('prtDataSetBigClass:defaultSummary','prtDataSetBig* classes provide default values (nan) for many fields, since these take time to calculate; use ds = ds.summaryBuild to build the summary');
            warning off prtDataSetBigClass:defaultSummary
            
            summary = struct('upperBounds',nan,'lowerBounds',nan,'nFeatures',nan,...
                'nTargetDimensions',nan,'uniqueClasses',nan,'nClasses',nan,...
                'isMary',nan,'nObservations',nan,'nBlocks',nan,'targetCache',nan,...
                'isSummaryValid',false);
        end
    end
end