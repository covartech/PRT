classdef prtPreProcLogDisc < prtPreProc
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Logistic Discriminant'
        nameAbbreviation = 'LogDisc'
        isSupervised = true;
    end
    
    properties (SetAccess=private)
        % General Classifier Properties
        logDiscWeights = [];
        logDiscMeans = [];
    end
    
    methods
        function Obj = prtPreProcLogDisc(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            LogDisc = prtClassLogisticDiscriminant;
            for iFeature = 1:DataSet.nFeatures
                cLogDisc = LogDisc.train(DataSet.retainFeatures(iFeature));
                Obj.logDiscMeans(iFeature) = cLogDisc.w(1);
                Obj.logDiscWeights(iFeature) = cLogDisc.w(2);
            end
            
            %Obj.logDiscWeights
            %Obj.stds = nanstd(DataSet.getObservations(),0,1);
            %Obj.means = nanmean(DataSet.getObservations(),1);
        end
        
        function DataSet = runAction(Obj,DataSet)
            sigmaFn = @(x) 1./(1 + exp(-x));
            for iFeature = 1:length(Obj.logDiscWeights)
                DataSet = DataSet.setObservations(sigmaFn(DataSet.getObservations(:,iFeature)*Obj.logDiscWeights(iFeature) + Obj.logDiscMeans(iFeature)),:,iFeature);
            end
        end
        
    end
    
end