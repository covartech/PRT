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
                h(i) = plot(self(i).far,self(i).pd);
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