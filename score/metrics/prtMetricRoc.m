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
        
        function varargout = plot(self)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:length(self)
                h(i) = plot(self(i).pf,self(i).pd);
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
        
        function varargout = plotRocFar(self)
            
            holdState = ishold;
            
            h = gobjects(length(self),1);
            for i = 1:length(self)
                h(i) = plot(self(i).nfa./self(i).farDenominator,self(i).pd);
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