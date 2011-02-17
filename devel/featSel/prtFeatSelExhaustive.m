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
%    evaluationMetric      - The metric to be used to determine which
%                            features are selected. evaluationMetric must
%                            be a function handle. The function handle must
%                            be in the form:
%                            @(dataSet)prtEval(prtClass, dataSet, varargin)
%                            where prtEval is a prtEval function, prtClass
%                            is a prt classifier object, and varargin 
%                            represents optional input arguments to a 
%                            prtEval function.
%    Peformance            - The performance obtained by the using the
%                            features selected.
%    selectedFeatures      - The indices of the features selected that gave
%                            the best performance.
%
%   A prtFeatSelExhaustive object inherits the TRAIN and RUN methods from prtClass.
%
%   Example:
% 
%   dataSet = prtDataGenFeatureSelection;      % Generate a data set
%   featSel = prtFeatSelExhaustive;   % Create a feature selction object
%   featSel.nFeatures = 1;            % Select only one feature of the data
%   featSel = featSel.train(dataSet); % Train the feature selection object
%   outDataSet = featSel.run(dataSet);% Extract the data set with only the
%                                     % selected features
%
%   %   Change the scoring function to prtScorePdAtPf, and change the
%   %   classification method to prtClassMAP
%
%   featSel.evaluationMetric = @(DS)prtEvalPdAtPf( prtClassMap, DS, .9);
%
%   featSel = featSel.train(dataSet); 
%   outDataSet = featSel.run(dataSet);
%
% See Also:  prtFeatSelStatic, prtFeatSelSfs

    properties (SetAccess=private)
        name = 'Exhaustive Feature Selection'
        nameAbbreviation = 'Efs'
    end
    
    properties
        nFeatures = 3;                    % The number of features to be selected
        showProgressBar = true;           % Whether or not the progress bar should be displayed
        evaluationMetric = @(DS)prtEvalAuc(prtClassFld,DS);   % The metric used to evaluate performance
    end
    
    properties (SetAccess = protected)
        performance = [];                 % The best performance of the selected feature set
        selectedFeatures = [];            % The indices of the features selected 
    end
    
    methods
        function Obj = prtFeatSelExhaustive(varargin)     
            Obj.isCrossValidateValid = false;
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.nFeatures(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val);
                error('prt:prtFeatSelExhaustive','nFeatures must be a positive scalar integer.');
            end
            Obj.nFeatures = val;
        end
        
        function Obj = set.showProgressBar(Obj,val)
            if ~prtUtilIsLogicalScalar(val);
                error('prt:prtFeatSelExhaustive','showProgressBar must be a scalar logical.');
            end
            Obj.showProgressBar = val;
        end
        
        function Obj = set.evaluationMetric(Obj,val)
            assert(isa(val, 'function_handle') && nargin(val)>=1,'prt:prtFeatSelExhaustive','evaluationMetric must be a function handle that accepts one input argument; e.g. @(DS)prtEvalPdAtPf( prtClassMap, DS, .9)');
            Obj.evaluationMetric = val;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function Obj = trainAction(Obj,DS)
            
            bestPerformance = -inf;
            bestChoose = [];
            
            Obj.nFeatures = min(DS.nFeatures,Obj.nFeatures);
            maxIterations = nchoosek(DS.nFeatures,Obj.nFeatures);
            
            iterationCount = 1;
            nextChooseFn = prtUtilNextChoose(DS.nFeatures,Obj.nFeatures);
            firstChoose = nextChooseFn();
            currChoose = firstChoose;
            
            finishedFunction = @(current) isequal(current,firstChoose);
            
            if Obj.showProgressBar
                h = prtUtilWaitbarWithCancel('Exhaustive Feature Selection');
            end
            
            notFinished = true;
            canceled = false;
            try
                while notFinished;
                    if Obj.showProgressBar
                        prtUtilWaitbarWithCancel(iterationCount/maxIterations,h);
                    end
                    
                    tempDataSet = DS.retainFeatures(currChoose);
                    currPerformance = Obj.evaluationMetric(tempDataSet);
                    
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
            catch ME
                delete(h);
                throw(ME);
            end
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
