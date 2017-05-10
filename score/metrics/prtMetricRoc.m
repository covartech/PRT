classdef prtMetricRoc
    % prtMetricRoc
    %   Undocumented single-output object for prtScoreRoc
    % 
    properties
        nTargets
        nNonTargets
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
        
        function pfOut = pfAtPdValues(self,pdPoints)
            if numel(self)>1
                pfOut = cell(size(self));
                for iSelf = 1:numel(self)
                    pfOut{iSelf} = self(iSelf).pfAtPdValues(pdPoints);
                end
                return
            end
            
            % return nan values if past ROC curve
            tmpPf = self.pf;
            tmpPf(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = Inf;
            
            indOut = arrayfun(@(s)find(tmpPd>s,1),pdPoints);
            %ind = find(self.far > farPoints,1,'first');
            pfOut = tmpPf(indOut);
        end
        
        function [farOut,indOut] = farAtPdValues(self,pdPoints)
            if numel(self)>1
                farOut = cell(size(self));
                indOut = cell(size(self));
                for iSelf = 1:numel(self)
                    [farOut{iSelf},indOut{iSelf}] = self(iSelf).farAtPdValues(pdPoints);
                end
                return
            end
            
            % return nan values if past ROC curve
            tmpFar = self.far;
            tmpFar(end+1) = Inf;
            tmpPd = self.pd;
            tmpPd(end+1) = Inf;
            
            indOut = arrayfun(@(s)find(tmpPd>=s,1,'first'),pdPoints);
            %ind = find(self.far > farPoints,1,'first');
            farOut = tmpFar(indOut);
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
        function varargout = plotNfa(self,varargin)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:numel(self)
                h(i) = plot(self(i).nfa,self(i).pd,varargin{:});
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
        
        
        function varargout = plotFar(self,varargin)
            
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
        function varargout = plotRocFar(self,varargin)
            varargout = cell(nargout,1);
            [varargout{:}] = plotFar(self,varargin{:});
        end
        
        function ds = assignValue(self, ds, fieldName)
            % Find the closest tau and use the corresponding field name as the updated X confidence
            
            assert(ds.nFeatures == length(self),'prt:prtMetricRoc:assignValue','Invalid input. Number of features in dataset and number of rocs must match');
            if nargin < 3 || isempty(fieldName)
                fieldName = 'pf';
            end
            assert(ismember(fieldName, {'pd','pf','nfa','far'}),'prt:prtMetricRoc:assignValue','Invalid input. fieldName must be one of {''pd'',''pf'',''nfa''}');
            
            useFar = false;
            if strcmpi(fieldName,'far')
                fieldName = 'nfa';
                useFar = true;
            end
            
            flipTau = false;
            newX = nan([ds.nObservations length(self)]);
            for iRoc = 1:length(self)
                
                cX = ds.X(:,iRoc);
                nTau = numel(self(iRoc).tau);
                if flipTau
                    flippedTau = flipud(self(iRoc).tau);
                end
                
                binInd = zeros(size(cX,1),1);
                for iObs = 1:size(cX,1)
                    cVal = cX(iObs);
                    if isnan(cVal)
                        cBin = nan;
                    elseif ~isfinite(cVal)
                        % +/-Inf
                        if flipTau
                            if cVal > 0 % +Inf
                                cBin = nTau;
                            else %-Inf
                                cBin = 1;
                            end
                        else
                            if cVal > 0 % Inf
                                cBin = 1;
                            else
                                cBin = nTau; % -Inf
                            end
                        end
                    else
                        if flipTau
                            cBin = find(cVal >= flippedTau,1,'last');
                        else
                            cBin = find(self(iRoc).tau >= cVal, 1, 'last');
                        end
                        
                        if isempty(cBin)
                            cBin = 1; % First bin?..
                        end
                    end
                    binInd(iObs) = cBin;
                end
                
                %[~, binInd] = histc(cX,flippedTau);
                
                nonNans = ~isnan(binInd);
                if flipTau
                    flippedField = flipud(self(iRoc).(fieldName));
                    newX(nonNans,iRoc) = flippedField(binInd(nonNans)); 
                else
                    newX(nonNans,iRoc) = self(iRoc).(fieldName)(binInd(nonNans)); 
                end
            end
            
            if useFar
                newX = newX ./ self.farDenominator;
            end
            
            ds.X = newX;
        end
        function pauc = aucFar(self, maxFar)
            
            if nargin < 2 || isempty(maxFar)
                maxFar = -inf; % This will be ignored
            end
            
            pauc = zeros(size(self));
            for iRoc = 1:numel(self)
                
                nTarget = self(iRoc).nTargets;
                uPd = linspace(0,1,nTarget+1);
                uPdFar = self(iRoc).farAtPdValues(uPd);
                
                cX = uPdFar(:);
                cY = uPd(:);
                                
                keep = cX <= maxFar;
                cX = cX(keep);
                cY = cY(keep);
                
                % Append a last point @ maxFar to ensure we get the final
                % rectangle up to the requested FAR - note: Can optionally
                % include the trapezoidal extension... but that's not
                % actually the PD you would get based on the data we've
                % seen.  It's a conundrum and the extension is complicated,
                % and adds no real benefit.
                cX = cat(1,cX,maxFar);
                cY = cat(1,cY, cY(end));
                
                pauc(iRoc) = trapz(cX,cY);
            end
        end
    end
end
