classdef prtFeatSelSbs < prtFeatSel
% prtFeatSelSfs   Sequential forward feature selection object.
%
%    FEATSEL = prtFeatSelSfs creates a sequental forward feature selection
%    object.
%
%    FEATSEL = prtFeatSelSfs(PROPERTY1, VALUE1, ...) constructs a
%    prttFeatSelSfs object FEATSEL with properties as specified by
%    PROPERTY/VALUE pair
%
%    A prtFeatSelSfsobject has the following properties:
%
%    nFeatures             - The number of features to be selected
%    showProgressBar       - Flag indicating whether or not to show the
%                            progress bar during feature selection.
%    evaluationMetric      - The metric to be used to determine which
%                            features are selected. evaluationMetric must
%                            be a function handle. The function handle must
%                            be in the form:
%                            @(dataSet)prtEval(prtClass, dataSet, varargin)
%                            where prtEvak is a prtEval function, prtClass
%                            is a prt classifier object, and varargin
%                            represents optional input arguments to a
%                            prtEval function.
%
%    peformance            - The performance obtained by the using the
%                            features selected.
%    selectedFeatures      - The indices of the features selected that gave
%                            the best performance.
%
%   A prtFeatSelExhaustive object inherits the TRAIN and RUN methods
%   from prtClass.
%
%   Example:
%
%   dataSet = prtDataGenFeatureSelection;         % Generate a data set
%   featSel = prtFeatSelSfs;          % Create a feature selction object
%   featSel.nFeatures = 3;            % Select only one feature of the data
%   featSel = featSel.train(dataSet); % Train the feature selection object
%   outDataSet = featSel.run(dataSet);% Extract the data set with only the
%                                     % selected features
%
%   %   Change the scoring function to prtScorePdAtPf, and change the
%   %   classification method to prtClassMAP
%
%   featSel.evaluationMetric = @(DS)prtEvalPdAtPf(prtClassMap, DS, .9);
%
%   featSel = featSel.train(dataSet);
%   outDataSet = featSel.run(dataSet);
%
 % See Also:  prtFeatSelStatic, prtFeatSelExhaustive







    properties (SetAccess=private)
        name = 'Sequentual Backward Search'
        nameAbbreviation = 'SBS'
    end
    
    properties
        % General Classifier Properties
        nFeatures = 3;                    % The number of features to be selected
        evaluationMetric = @(DS)prtEvalAuc(prtClassFld,DS);   % The metric used to evaluate performance
    end
    
    properties (SetAccess = protected)
        performance = [];        % The evalutationMetric for the selected features
        selectedFeatures = [];   % The integer values of the selected features
    end
    
    
    methods
        function Obj = prtFeatSelSbs(varargin)
            Obj.isCrossValidateValid = false;
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nFeatures(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val);
                error('prt:prtFeatSelSfs','nFeatures must be a positive scalar integer.');
            end
            Obj.nFeatures = val;
        end
        
        function Obj = set.evaluationMetric(Obj,val)
            assert(isa(val, 'function_handle') && nargin(val)>=1,'prt:prtFeatSelExhaustive','evaluationMetric must be a function handle that accepts one input argument.');
            Obj.evaluationMetric = val;
        end
        
    end
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DS)
            
            nFeatsTotal = DS.nFeatures;
            nSelectFeatures = min(nFeatsTotal,Obj.nFeatures);
            nFeatsToRemove = nFeatsTotal-nSelectFeatures;
            
            Obj.performance = nan(1,nSelectFeatures);
            Obj.selectedFeatures = nan(1,nSelectFeatures);
            
            sbsSelectedFeatures = 1:nFeatsTotal;
            
            if Obj.showProgressBar
                h = prtUtilProgressBar(0,'Feature Selection - SBS','autoClose',true);
            end
            
            for j = 1:nFeatsToRemove
                
                if Obj.showProgressBar && j == 1
                    h2 = prtUtilProgressBar(0,sprintf('Selecting Feature %d',j),'autoClose',false);
                elseif Obj.showProgressBar
                    h2.titleStr = sprintf('Selecting Feature %d',j);
                    h2.update(0);
                end
                
                cPerformance = nan(1,length(sbsSelectedFeatures));
                for i = 1:length(sbsSelectedFeatures)
                    currentFeatureSet = sbsSelectedFeatures;
                    currentFeatureSet(i) = [];
                    tempDataSet = DS.retainFeatures(currentFeatureSet);
                    
                    cPerformance(i) = Obj.evaluationMetric(tempDataSet);
                    
                    if Obj.showProgressBar
                        h2.update(i/length(sbsSelectedFeatures));
                    end
                end
                
                if Obj.showProgressBar
                    % Make sure it's closed.
                    h2.update(1);
                end
                
                if all(~isfinite(cPerformance))
                    error('prt:prtFeatSelSfs','All evaluation matrics resulted in non-finite values. Check evalutionMetric');
                end
                
                % Randomly choose the next feature if more than one provide the same performance
                [val,worstFeatInd] = max(cPerformance);
                sbsSelectedFeatures(worstFeatInd) = [];
                
                if Obj.showProgressBar
                    h.update(j/nFeatsToRemove);
                end
            end
            Obj.performance = val;
            Obj.selectedFeatures = sbsSelectedFeatures;
            
            if Obj.showProgressBar
                % Make sure it's closed.
                h.update(1);
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            if ~Obj.isTrained
                error('prt:prtFeatSelSfs','Attempt to run a prtFeatSel that is not trained');
            end
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
    end
end
