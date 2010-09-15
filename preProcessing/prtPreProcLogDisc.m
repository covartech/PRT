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
    
    %
    %     methods (Hidden = true)
    %         function featureNames = updateFeatureNames(obj,featureNames) %#ok<MANU>
    %             for i = 1:length(featureNames)
    %                 featureNames{i} = sprintf('LogisticDiscrimant %d',i);
    %             end
    %         end
    %     end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            if ~DataSet.isBinary
                error('prt:prtPreProcLogDisc:MaryDataNotSupported','prtPreProcLogDisc requires binary labeled data, but dataSet.nClasses is %d',DataSet.nClasses);
            end
            LogDisc = prtClassLogisticDiscriminant;
            for iFeature = 1:DataSet.nFeatures
                cLogDisc = LogDisc.train(DataSet.retainFeatures(iFeature));
                Obj.logDiscMeans(iFeature) = cLogDisc.w(1);
                Obj.logDiscWeights(iFeature) = cLogDisc.w(2);
            end
            
        end
        
        function DataSet = runAction(Obj,DataSet)
            sigmaFn = @(x) 1./(1 + exp(-x));
            for iFeature = 1:length(Obj.logDiscWeights)
                DataSet = DataSet.setObservations(sigmaFn(DataSet.getObservations(:,iFeature)*Obj.logDiscWeights(iFeature) + Obj.logDiscMeans(iFeature)),:,iFeature);
            end
        end
        
    end
    
end