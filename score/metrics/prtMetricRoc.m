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
        
        targetAreas
        laneArea
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
        
        function varargout = plotRocFarQuiver(self,varargin)
            % plotH = plotRocFarQuiver(self,plotArgs)
            % plotH = plotRocFarQuiver(self,{plotArgs},{quiverArgs})
            if ~isempty(varargin) && isnumeric(varargin{1})
                nQuiverPts = varargin{1};
                varargin(1) = [];
            else
                nQuiverPts = Inf;
            end
            
            if numel(varargin) == 2 && isa(varargin{1},'cell') && isa(varargin{2},'cell')
                plotArgs = varargin{1};
                quiverArgs = varargin{2};
            else
                plotArgs = varargin;
                quiverArgs = varargin;
            end
            
            holdState = ishold;
            
            h = gobjects(length(self),2);
            for i = 1:length(self)
                s = self(i);
                
                nTarget = numel(s.targetAreas);
                uPd = linspace(0,1,nTarget+1);
                uPdFar = s.farAtPdValues(uPd);
                
                % plot trapezoidal far curve
                h(i,1) = plot(uPdFar(:),uPd(:),plotArgs{:});
                if i==1, hold on, end % mimic previous hold state
                
                totalTargetArea = sum(s.targetAreas);
                remainingTargetArea = totalTargetArea - cat(1,0,cumsum(s.targetAreas));
                
                deltaPd = 1/nTarget;
        
                if isempty(s.laneArea)
                    lArea = s.farDenominator;
                else
                    lArea = s.laneArea;
                end
                
                nQuiverPts = min(nQuiverPts,nTarget);
                pInd = floor(linspace(1,numel(uPd),nQuiverPts));
                
                % vx = (alarmArea/lArea)*(1/s.farDenominator) = 1/lArea
                vx = 1/lArea; % every time FAR increases by this (+1 alarm)
                vy = deltaPd*remainingTargetArea/lArea; % Pd increases by this in expectation (probability of hit)
                
                vn = sqrt(vx.^2 + vy.^2);
                vx = vx./vn;
                vy = vy./vn;
                
                if isempty(quiverArgs)
                    quiverArgs = {0.1}; % arrow relative size
                end
                
                h(i,2) = quiver(uPdFar(pInd),uPd(pInd),vx(pInd),vy(pInd),quiverArgs{:});
                
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
        
        function varargout = plotRocFarQuiverField(self,varargin)
            % plotH = plotRocFarQuiver(self,plotArgs)
            % plotH = plotRocFarQuiver(self,{plotArgs},{quiverArgs})
            if ~isempty(varargin) && isnumeric(varargin{1})
                nQuiverPts = varargin{1};
                varargin(1) = [];
            else
                nQuiverPts = Inf;
            end
            
            if numel(varargin) == 2 && isa(varargin{1},'cell') && isa(varargin{2},'cell')
                plotArgs = varargin{1};
                quiverArgs = varargin{2};
            else
                plotArgs = varargin;
                quiverArgs = varargin;
            end
            
            holdState = ishold;
            
            h = gobjects(length(self),2);
            for i = 1:length(self)
                s = self(i);
                
                nTarget = numel(s.targetAreas);
                uPd = linspace(0,1,nTarget+1)';
                uPdFar = s.farAtPdValues(uPd);
                
                % plot trapezoidal far curve
                h(i,1) = plot(uPdFar,uPd,plotArgs{:});
                if i==1, hold on, end % mimic previous hold state
                
                totalTargetArea = sum(s.targetAreas);
                remainingTargetArea = totalTargetArea - cat(1,0,cumsum(s.targetAreas));
                
                deltaPd = 1/nTarget;
        
                if isempty(s.laneArea)
                    lArea = s.farDenominator;
                else
                    lArea = s.laneArea;
                end
                
                nQuiverPts = min(nQuiverPts,nTarget);
                pInd = floor(linspace(1,numel(uPd),nQuiverPts));
                
                % vx = (alarmArea/lArea)*(1/s.farDenominator) = 1/lArea
                vx = 1/lArea; % every time FAR increases by this (+1 alarm)
                vy = deltaPd*remainingTargetArea/lArea; % Pd increases by this in expectation (probability of hit)
                
                vn = sqrt(vx.^2 + vy.^2);
                vx = vx./vn;
                vy = vy./vn;
                
                if isempty(quiverArgs)
                    quiverArgs = 0.1; % arrow relative size
                end
                
                uPdFar(~isfinite(uPdFar)) = nan;
                farVals = linspace(0,max(uPdFar),nQuiverPts);
                farVals = repmat(farVals,nQuiverPts,1);
                pdVals = repmat(uPd(pInd),1,nQuiverPts);
                vxVals = repmat(vx(pInd),1,nQuiverPts);
                vyVals = repmat(vy(pInd),1,nQuiverPts);
                
                
                h(i,2) = quiver(farVals,pdVals,vxVals,vyVals,quiverArgs{:});
                
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
        
        function varargout = plotRocFarChanceNan(self,varargin)
            % plotH = plotRocFarChanceNan(self)
            
            if ~isempty(varargin) && isnumeric(varargin{1})
                farCutOff = varargin{1};
                varargin(1) = [];
            else
                farCutOff = 10;
            end
            
            plotArgs = varargin;
            
            holdState = ishold;
            
            h = gobjects(length(self),2);
            for i = 1:length(self)
                s = self(i);
                
                nTarget = numel(s.targetAreas);
                uPd = linspace(0,1,nTarget+1);
                uPdFar = s.farAtPdValues(uPd);
                
                uPd = uPd(:);
                uPdFar = uPdFar(:);
                
                totalTargetArea = sum(s.targetAreas);
                remainingTargetArea = totalTargetArea - cat(1,0,cumsum(s.targetAreas));
                
                deltaPd = 1/nTarget;
        
                if isempty(s.laneArea)
                    lArea = s.farDenominator;
                else
                    lArea = s.laneArea;
                end
                
                %deltaPdVec = cat(1,1,diff(uPd(:)));
                %deltaFarVec = cat(1,0,diff(uPdFar(:)));
                %localRocAngle = atan2(deltaPdVec, deltaFarVec);
                
                vx = 1/lArea; % every time FAR increases by this (+1 alarm)
                vy = deltaPd*remainingTargetArea/lArea; % Pd increases by this in expectation (probability of hit)
                
                vy = cat(1, vy(1),vy(1:end-1));
                
                vn = sqrt(vx.^2 + vy.^2);
                vx = vx./vn;
                vy = vy./vn;
                
                localRocChanceAngle = atan2(vy,vx);
                
                localDeltaFar = deltaPd./tan(localRocChanceAngle);
                
                uPdFarChance = zeros(length(uPdFar),length(uPd));
                for iPd = 1:length(uPd)
                    if iPd == 1
                        uPdFarChance(1:end,iPd) = cumsum(localDeltaFar);
                    else
                        uPdFarChance(1:(iPd-1),iPd) = uPdFar(1:(iPd-1));
                        uPdFarChance(iPd:end,iPd) = cumsum(localDeltaFar(iPd:end)) + uPdFar(iPd-1);
                    end
                end
                    
                %                 %%
                %                 plot(uPdFar, uPd(:),'k','lineWidth',3)
                %                 hold on, h = plot(uPdFarChance,uPd(:));
                %                 hold off
                %                 cmap = parula(length(h))*0.8;
                %                 for iLine = 1:length(h)
                %                     set(h(iLine),'color',cmap(iLine,:));
                %                 end
                %                 xlabel('FAR (#/m^2)');
                %                 ylabel('PD');
                %                 grid on
                %                 cvrS2('randomChancePRocs');
                %                 axis([0 1 0 1])
                %                 cvrS2('randomChancePRocsZoom');
                %                 %%
               
                % If we are not going out to high FAR we must truncate each curve at the appropriate level
                uPdFarChanceCut = uPdFarChance;
                uPdChanceCut = repmat(uPd,[1 length(uPd)]);
                for iPd = 1:length(uPd)
                    cutInd = find(uPdFarChance(:,iPd) > farCutOff,1,'first');
                    if ~isempty(cutInd)
                        uPdFarChanceCut(cutInd:end,iPd) = farCutOff;
                        uPdChanceCut(cutInd:end,iPd) = uPdChanceCut(cutInd-1,iPd);
                    end
                end
                
                curveAreas = zeros(length(uPd),1);
                for iPd = 1:length(uPd)
                    cX = uPdFarChanceCut(:,iPd);
                    cY = uPdChanceCut(:,iPd);
                    if max(cX) < farCutOff
                        cX = cat(1,cX,farCutOff);
                        cY = cat(1,cY, cY(end));
                    end
                    
                    curveAreas(iPd) = trapz(cX,cY);
                end
                
                [~, stopInd] = max(curveAreas);
               
                uPdFarThresh = uPdFar;
                uPdThresh = uPd;
                stopInd = max(min(stopInd,length(uPd)),1);
                if ~isempty(stopInd)
                    uPdFarThresh(stopInd:end) = nan;
                    uPdThresh(stopInd:end) = nan;
                end
                
                %plot(uPdFar(1:end-1),curveAreas(2:end)/farCutOff*100), ylabel('% pAUC'), xlabel('FAR of Switching to Random (#/m^2)'), grid on, cvrS2('areaVsSwitchPoint')
                
                h(i,1) = plot(uPdFar(:),uPd(:),plotArgs{:},'LineWidth',1);
                
                if i==1, hold on, end
                
                h(i,2) = plot(uPdFarThresh(:),uPdThresh(:),plotArgs{:},'LineWidth',3);
                
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
            assert(ismember(fieldName, {'pd','pf','nfa','far'}),'prt:prtMetricRoc:assignValue','Invalid input. fieldName must be one of {''pd'',''pf'',''nfa''}');
            
            useFar = false;
            if strcmpi(fieldName,'far')
                fieldName = 'nfa';
                useFar = true;
            end
            
            
            newX = nan([ds.nObservations length(self)]);
            for iRoc = 1:length(self)
                
                cX = ds.X(:,iRoc);
                
                flippedTau = flipud(self(iRoc).tau);
                
                binInd = zeros(size(cX,1),1);
                for iObs = 1:size(cX,1)
                    cVal = cX(iObs);
                    if isnan(cVal)
                        cBin = nan;
                    elseif ~isfinite(cVal)
                        % +/-Inf
                        if cVal > 0
                            cBin = size(cX,1);
                        else
                            cBin = 1;
                        end
                    else
                        cBin = find(cVal >= flippedTau,1,'last');
                    end
                    binInd(iObs) = cBin;
                end
                
                %[~, binInd] = histc(cX,flippedTau);
                
                flippedField = flipud(self(iRoc).(fieldName));
                
                nonNans = ~isnan(binInd);
                
                newX(nonNans,iRoc) = flippedField(binInd(nonNans)); 
            end
            
            if useFar
                newX = newX ./ self.farDenominator;
            end
            
            ds.X = newX;
        end
    end
end