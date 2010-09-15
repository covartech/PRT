classdef prtFeatSelSfs < prtFeatSel
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
%    EvaluationMetric      - The metric to be used to determine which
%                            features are selected. EvaluationMetric must
%                            be a function handle. The function handle must
%                            be in the form:
%                            @(dataSet)prtEval(prtClass, dataSet, varargin)
%                            where prtEvak is a prtEval function, prtClass
%                            is a prt classifier object, and varargin
%                            represents optional input arguments to a
%                            prtEval function.
%
%    Peformance            - The performance obtained by the using the
%                            features selected.
%    selectedFeatures      - The indices of the features selected that gave
%                            the best performance.
%
%   A prtFeatSelExhaustive object inherits the TRAIN and RUN methods
%   from prtClass.
%
%   Example:
%
%   dataSet = prtDataGenCircles;         % Generate a data set
%   featSel = prtFeatSelSfs;          % Create a feature selction object
%   featSel.nFeatures = 1;            % Select only one feature of the data
%   featSel = featSel.train(dataSet); % Train the feature selection object
%   outDataSet = featSel.run(dataSet);% Extract the data set with only the
%                                     % selected features
%
%   %   Change the scoring function to prtScorePdAtPf, and change the
%   %   classification method to prtClassMAP
%
%   featSel.EvaluationMetric = @(DS)prtEvalPdAtPf(prtClassMap, DS, .9);
%
%   featSel = featSel.train(dataSet);
%   outDataSet = featSel.run(dataSet);
%
 % See Also:  prtFeatSelStatic, prtFeatSelExhaustive
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Sequentual Feature Selection'
        nameAbbreviation = 'SFS'
        isSupervised = true;
    end
    
    properties
        % General Classifier Properties
        nFeatures = 3;                    % The number of features to be selected
        showProgressBar = true;           % Whether or not the progress bar should be displayed
        EvaluationMetric = @(DS)prtEvalAuc(prtClassFld,DS);   % The metric used to evaluate performance
        
        performance = [];                 % The best performance achieved after training
        selectedFeatures = [];
    end
    
    
    
    methods
        
        
        % Constructor %%
        
        % Allow for string, value pairs
        function Obj = prtFeatSelSfs(varargin)
            Obj.isCrossValidateValid = false;
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        
    end
    methods (Access = protected)
        
        % Train %%
        function Obj = trainAction(Obj,DS)
            
            nFeatsTotal = DS.nFeatures;
            
            sfsPerformance = zeros(min(nFeatsTotal,Obj.nFeatures),1);
            sfsSelectedFeatures = [];
            
            canceled = false;
            try
                for j = 1:min(nFeatsTotal,Obj.nFeatures);
                    
                    if Obj.showProgressBar
                        h = prtUtilWaitbarWithCancel('SFS');
                    end
                    
                    availableFeatures = setdiff(1:nFeatsTotal,sfsSelectedFeatures);
                    performance = nan(size(availableFeatures));
                    for i = 1:length(availableFeatures)
                        currentFeatureSet = cat(2,sfsSelectedFeatures,availableFeatures(i));
                        tempDataSet = DS.retainFeatures(currentFeatureSet);
                        performance(i) = Obj.EvaluationMetric(tempDataSet);
                        
                        if Obj.showProgressBar
                            prtUtilWaitbarWithCancel(i/length(availableFeatures),h);
                        end
                        
                        if ~ishandle(h)
                            canceled = true;
                            break
                        end
                    end
                    
                    if Obj.showProgressBar && ~canceled
                        close(h);
                    end
                    
                    if canceled
                        break
                    end
                    
                    % Randomly choose the next feature if more than one provide the same performance
                    [val,newFeatInd] = max(performance);
                    newFeatInd = find(performance == val);
                    newFeatInd = newFeatInd(max(1,ceil(rand*length(newFeatInd))));
                    % In the (degenerate) case when rand==0, set the index to the first one
                    
                    sfsPerformance(j) = val;
                    sfsSelectedFeatures(j) = [availableFeatures(newFeatInd)];
                end
                Obj.performance = sfsPerformance;
                Obj.selectedFeatures = sfsSelectedFeatures;
                
            catch ME
                close(h);
                throw(ME);
            end
        end
        
        
        
        % Run %
        function DataSet = runAction(Obj,DataSet) %%
            if ~Obj.isTrained
                error('prt:prtFeatSelSfs','Attempt to run a prtFeatSel that is not trained');
            end
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
        
        
    end
    
    
end
