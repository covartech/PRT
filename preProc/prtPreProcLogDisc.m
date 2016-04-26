classdef prtPreProcLogDisc < prtPreProcClass
    % prtPreProcLogDisc   Histogram equalization processing
    %
    %   LOGDISC = prtPreProcLogDisc creates a logistic discriminant pre
    %   processing object. A prtPreProcLogDisc object processes the input data
    %   so that each feature dimension is scaled between 0 and 1 to best
    %   match the data set class labels.
    % 
    %   prtPreProcLogDisc has no user settable properties.
    %
    %   A prtPreProcLogDisc object also inherits all properties and
    %   functions from the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenUnimodal;     % Load a data set
    %   logDisc = prtPreProcLogDisc;      % Create a pre processing object
    %                                
    %   logDisc = logDisc.train(dataSet);  % Train
    %   dataSetNew = logDisc.run(dataSet); % Run
    % 
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('LogDisc Data');
    %
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows







    properties (SetAccess=private)
        name = 'Logistic Discriminant' % 'Logistic Discriminant'
        nameAbbreviation = 'LogDisc' % LogDisc
    end
    
    properties (SetAccess=private, Hidden = true)
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
    
    methods (Access = protected, Hidden = true)
        
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
            X = nan(DataSet.nObservations,DataSet.nFeatures);
            for iFeature = 1:length(Obj.logDiscWeights)
                X(:,iFeature) = sigmaFn(DataSet.X(1:DataSet.nObservations,iFeature)*Obj.logDiscWeights(iFeature) + Obj.logDiscMeans(iFeature));
            end
            DataSet = DataSet.setObservations(X);
        end
        
    end
    
end
