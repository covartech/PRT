classdef prtDataSetBigClass < prtDataSetBig & prtDataInterfaceCategoricalTargetsBig
    % prtDataSetBigClass is a class for prtDataSetBig that are for
    % classification. It is currently a placeholder for future
    % classification specific helper methods.

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


    
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
