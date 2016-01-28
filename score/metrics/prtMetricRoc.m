classdef prtMetricRoc
    % prtMetricRoc
    %   Undocumented single-output object for prtScoreRoc
    % 
    properties
        pd
        pf
        nfa
        farDenominator = nan;
        tau
        auc
        
        thresholds = [];
    end
    properties (Dependent)
        far
    end
    
    methods
        function self = prtMetricRoc(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function val = get.far(self)
            val = self.nfa./self.farDenominator;
        end
        
        function [meanRoc,stdRoc,farVals] = getRocFarStatistics(self,farVals)
            % [meanRoc,stdRoc] = getRocStatistics(self,nPoints)
            % [meanRoc,stdRoc] = getRocStatistics(self,farVals)
            % get mean & std of a bunch of ROCs
            if nargin < 2
                farVals = 250;
            end
            
            if numel(farVals) == 1
                nPoints = 250;
                allFar = cat(1,self(:).far);
                farVals = linspace(0,max(allFar),nPoints);
            end
            
            pdVals = self.pdAtFarValues(farVals);
            pdVals = cat(2,pdVals{:});
            
            meanRoc = nanmean(pdVals,2);
            stdRoc = nanstd(pdVals,[],2);
            
        end
        
        function pdOut = pdAtFarValues(self,farPoints)
            if numel(self)>1
                pdOut = cell(size(self));
                for iSelf = 1:numel(self)
                    pdOut{iSelf} = self(iSelf).pdAtFarValues(farPoints);
                end
                return
            end
            
            tmpFar = self.far;
            tmpFar(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = nan;
            
            indOut = arrayfun(@(s)find(tmpFar>s,1),farPoints);
            %ind = find(self.far > farPoints,1,'first');
            pdOut = tmpPd(indOut);
        end
        
        function pdOut = pdAtPfValues(self,pfPoints)
            if numel(self)>1
                pdOut = cell(size(self));
                for iSelf = 1:numel(self)
                    pdOut{iSelf} = self(iSelf).pdAtPfValues(pfPoints);
                end
                return
            end
            
            % return nan values if past ROC curve
            tmpPf = self.pf;
            tmpPf(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = nan;
            
            indOut = arrayfun(@(s)find(tmpPf>s,1),pfPoints);
            %ind = find(self.far > farPoints,1,'first');
            pdOut = tmpPd(indOut);
        end
        
        function self = atThreshold(self,threshold)
            
            index = find(self.tau > threshold,1,'last');
            self.pd = self.pd(index);
            self.nfa = self.nfa(index);
            self.pf = self.pf(index);
            self.tau = self.tau(index);
            self.auc = nan;
        end
        
        function varargout = plot(self,varargin)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:numel(self)
                h(i) = plot(self(i).pf,self(i).pd,varargin{:});
                hold on;
            end
            if ~holdState
                hold off
            end
            
            if nargout
                varargout = {h};
            else
                varargout = {};
            end
        end
        
        function varargout = plotRocFar(self,varargin)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:length(self)
                h(i) = plot(self(i).far,self(i).pd,varargin{:});
                hold on;
            end
            if ~holdState
                hold off
            end
            
            if nargout
                varargout = {h};
            else
                varargout = {};
            end
            
        end
        
        function ds = assignValue(self, ds, fieldName)
            % Find the closest tau and use the corresponding field name as the updated X confidence
            
            assert(ds.nFeatures == length(self),'prt:prtMetricRoc:assignValue','Invalid input. Number of features in dataset and number of rocs must match');
            if nargin < 3 || isempty(fieldName)
                fieldName = 'pf';
            end
            assert(ismember(fieldName, {'pd','pf','nfa'}),'prt:prtMetricRoc:assignValue','Invalid input. fieldName must be one of {''pd'',''pf'',''nfa''}');
            
            newX = nan([ds.nObservations length(self)]);
            for iRoc = 1:length(self)
                
                cX = ds.X(:,iRoc);
                
                flippedTau = flipud(self(iRoc).tau);
                [~, binInd] = histc(cX,flippedTau);
                
                flippedField = flipud(self(iRoc).(fieldName));
                
                newX(:,iRoc) = flippedField(binInd); 
                
            end
            
            ds.X = newX;
        end
    end
end