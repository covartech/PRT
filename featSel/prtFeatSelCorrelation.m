classdef prtFeatSelCorrelation < prtFeatSel
% prtFeatSelCorrelation   Maximum abs(correlation) feature selection
%
    properties (SetAccess=private)
        name = 'Correlation Feature Selection' % Sequentual Feature Selection
        nameAbbreviation = 'CorrFeatSel' % SFS
    end
    
    properties
        % General Classifier Properties
        nFeatures = 3;
        useAbsCorr = true;
        featureCorrelationToTarget = [];
        featureCorrelationToTargetSorted = [];
        featureSortedIndices = [];
    end
    
    properties (SetAccess = protected)
        performance = [];        % The evalutationMetric for the selected features
        selectedFeatures = [];   % The integer values of the selected features
    end
    
    
    methods
        function self = prtFeatSelCorrelation(varargin)
            self.isCrossValidateValid = false;
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.nFeatures(self,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtFeatSelSfs','nFeatures must be a positive scalar integer.');
            end
            self.nFeatures = val;
        end        
    end
    
    methods (Access=protected,Hidden=true)
        
        function self = trainAction(self,ds)
            
            n = ds.nObservations;
            localX = ds.X;
            localY = ds.Y;
            localY = localY - mean(localY);
            localX = localX - mean(localX);
            % r = E[(X - mu_x)(Y - mu_y)] / (sigma_x * sigma_y)
            % Sample r:
            %   1/(n-1)*sum(x_score * y_score)
            x_score = localX./std(localX);
            y_score = localY./std(localY);
            
            self.featureCorrelationToTarget = 1./(n-1)*sum(x_score.*y_score);
            if ~self.useAbsCorr
                [~,inds] = sort(self.featureCorrelationToTarget,'descend');
            else
                [~,inds] = sort(abs(self.featureCorrelationToTarget),'descend');
            end
            self.featureCorrelationToTargetSorted = self.featureCorrelationToTarget(inds);
            self.featureSortedIndices = inds;
            self.performance = self.featureCorrelationToTargetSorted;
            self.selectedFeatures = inds(1:self.nFeatures);
        end
        
        function DataSet = runAction(self,DataSet)
            DataSet = DataSet.retainFeatures(self.selectedFeatures);
        end
        
    end
    
    methods
        function hStem = stem(self)
            
            sortedFeatureNames = self.dataSet.featureNames(self.selectedFeatures);
            hStem = stem(self.performance);
            hold on;
            hLine = plot(abs(self.performance),'k');
            hold off;
            set(gca,'xtick',1:length(self.performance));
            set(gca,'XTickLabel',sortedFeatureNames);
            set(gca,'XTickLabelRotation',20);
        end
    end
end
