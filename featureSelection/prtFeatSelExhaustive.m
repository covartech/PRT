classdef prtFeatSelExhaustive < prtFeatSel %
% prtFeatSelExhaustive   Exhaustive feature selection
%
%    FEATSEL = prtFeatSelExhaustive returns an exhaustive feature selection
%    object.
%
%    FEATSEL = prtFeatSelExhaustive(PROPERTY1, VALUE1, ...) constructs a
%    prttFeatSelExhaustive object FEATSEL with properties as specified by
%    PROPERTY/VALUE pair
%
%    A prtFeatSelExhaustive object has the following properties:
%
%    nFeatures             - The number of features to be selected
%    showProgressBar       - Flag indicating whether or not to show the
%                            progress bar during feature selection.
%    EvaluationMetric      - The metric to be used to determine which
%                            features are selected. EvaluationMetric must
%                            be a function handle. The function handle must
%                            be in the form @(dataSet)prtScore(dataSet,
%                            prtClass, varargin), where prtScore is a prt scoring
%                            object, prtClass is a prt classifier
%                            object, and varargin represents optional input
%                            arguments to a prtScoring object.
%    Peformance            - The performance obtained by the using the
%                            features selected.
%    selectedFeatures      - The indices of the features selected that gave
%                            the best performance.
%
%   A prtFeatSelExhaustive object inherits the TRAIN and RUN methods from prtClass.
%
%   Example:
% 
%   dataSet = prtDataCircles;         % Generate a data set
%   featSel = prtFeatSelExhaustive;   % Create a feature selction object
%   featSel.nFeatures = 1;            % Select only one feature of the data
%   featSel = featSel.train(dataSet); % Train the feature selection object
%   outDataSet = featSel.run(dataSet);% Extract the data set with only the
%                                     %  selected features
%
%   %   Change the scoring function to prtScorePdAtPf, and change the
%   %   classification method to prtClassMAP
%
%   featSel.EvaluationMetric = @(DS)prtScorePdAtPf(DS, prtClassMAP, .9);
%
%   featSel = featSel.train(dataSet); 
%   outDataSet = featSel.run(dataSet);
%
% See Also:  prtFeatSelStatic, prtFeatSelSfs

    properties (SetAccess=private)
        % Required by prtAction
        name = 'Exhaustive Feature Selection'
        nameAbbreviation = 'Efs'
        isSupervised = true;
    end
    
    properties
        % General Classifier Properties
        nFeatures = 3;                    % The number of features to be selected
        showProgressBar = true;           % Whether or not the progress bar should be displayed
        EvaluationMetric = @(DS)prtScoreAuc(DS,prtClassFld);   % The metric used to evaluate performance
        
        performance = [];                 % The best performance achieved after training
        selectedFeatures = [];            % The indices of the features selected by the training
    end
    
    methods
        
        % Constructor %%
        % Allow for string, value pairs
        function Obj = prtFeatSelExhaustive(varargin)     
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end    
    end
    
    methods (Access = protected)
        
        % Train %%
        function Obj = trainAction(Obj,DS)
            
            bestPerformance = -inf;
            bestChoose = [];
            
            Obj.nFeatures = min(DS.nFeatures,Obj.nFeatures);
            %warning off;
            maxIterations = nchoosek(DS.nFeatures,Obj.nFeatures);
            %warning on;
            
            iterationCount = 1;
            nextChooseFn = prtNextChoose(DS.nFeatures,Obj.nFeatures);
            firstChoose = nextChooseFn();
            currChoose = firstChoose;
            
            finishedFunction = @(current) isequal(current,firstChoose);
            
            if Obj.showProgressBar
                h = prtUtilWaitbarWithCancel('Exhaustive Feature Selection');
            end
            
            notFinished = true;
            canceled = false;
            while notFinished;
                if Obj.showProgressBar
                    prtUtilWaitbarWithCancel(iterationCount/maxIterations,h);
                end
                
                tempDataSet = DS.retainFeatures(currChoose);
                currPerformance = Obj.EvaluationMetric(tempDataSet);
                
                if any(currPerformance > bestPerformance) || isempty(bestChoose)
                    bestChoose = currChoose;
                    bestPerformance = currPerformance;
                elseif currPerformance == bestPerformance
                    bestChoose = cat(1,bestChoose,currChoose);
                    bestPerformance = cat(1,bestPerformance,currPerformance);
                end
                currChoose = nextChooseFn();
                notFinished = ~finishedFunction(currChoose);
                iterationCount = iterationCount + 1;
                
                if ~ishandle(h)
                    canceled = true;
                    break
                end
            end
            
            if Obj.showProgressBar && ~canceled
                delete(h);
            end
            drawnow;
            
            if size(bestChoose,1) > 1
                warning('prt:exaustiveSetsTie','Multiple identical performing feature sets found with performance %f; randomly selecting one feature set for output',bestPerformance(1));
                index = max(ceil(rand*size(bestChoose,1)),1);
                bestChoose = bestChoose(index,:);
                bestPerformance = bestPerformance(index,:);
            end
            Obj.performance = bestPerformance;
            Obj.selectedFeatures = bestChoose;
        end
        
         % Run %        
        function DataSet = runAction(Obj,DataSet) %%
            if ~Obj.isTrained
                error('prt:prtFeatSelExhaustive','Attempt to run a prtFeatSel that is not trained');
            end
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
     end
 end
