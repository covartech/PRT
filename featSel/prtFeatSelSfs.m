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

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


    properties (SetAccess=private)
        name = 'Sequentual Feature Selection' % Sequentual Feature Selection
        nameAbbreviation = 'SFS' % SFS
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
        function Obj = prtFeatSelSfs(varargin)
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
            
            Obj.performance = nan(1,nSelectFeatures);
            Obj.selectedFeatures = nan(1,nSelectFeatures);
            
            sfsSelectedFeatures = [];
            
            if Obj.showProgressBar
                h = prtUtilProgressBar(0,'Feature Selection - SFS','autoClose',true);
            end
            
            for j = 1:nSelectFeatures
                
                if Obj.showProgressBar && j == 1
                    h2 = prtUtilProgressBar(0,sprintf('Selecting Feature %d',j),'autoClose',false);
                elseif Obj.showProgressBar
                    h2.titleStr = sprintf('Selecting Feature %d',j);
                    h2.update(0);
                end
                
                if j > 1
                    sfsSelectedFeatures = Obj.selectedFeatures(1:(j-1));
                end
                
                availableFeatures = setdiff(1:nFeatsTotal,sfsSelectedFeatures);
                cPerformance = nan(size(availableFeatures));
                for i = 1:length(availableFeatures)
                    currentFeatureSet = cat(2,sfsSelectedFeatures,availableFeatures(i));
                    tempDataSet = DS.retainFeatures(currentFeatureSet);
                    
                    cPerformance(i) = Obj.evaluationMetric(tempDataSet);
                    
                    if Obj.showProgressBar
                        h2.update(i/length(availableFeatures));
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
                val = max(cPerformance);
                newFeatInd = find(cPerformance == val);
                newFeatInd = newFeatInd(max(1,ceil(rand*length(newFeatInd))));
                
                % In the (degenerate) case when rand==0, set the index to the first one
                Obj.performance(j) = val;
                Obj.selectedFeatures(j) = availableFeatures(newFeatInd);
                
                if Obj.showProgressBar
                    h.update(j/nSelectFeatures);
                end
            end
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
