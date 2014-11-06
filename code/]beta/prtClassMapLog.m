classdef prtClassMapLog < prtClass
 %prtClassMapLog  Maximum a Posteriori classifier with loglikelihoods
 %  returned
 

 %    CLASSIFIER = prtClassMap returns a Maximum a Posteriori classifier
 %
 %    CLASSIFIER = prtClassMap(PROPERTY1, VALUE1, ...) constructs a
 %    prtClassMAP object CLASSIFIER with properties as specified by
 %    PROPERTY/VALUE pairs.
 %
 %    A prtClassMap object inherits all properties from the abstract class
 %    prtClass. In addition is has the following property:
 %
 %    rvs    - A prtRv object. This property describes the random variable 
 %             model used for Maximum a Posteriori classification.
 %
 %    A prtClassMap object inherits inherits the TRAIN, RUN, CROSSVALIDATE
 %    and KFOLDS methods from prtClass.
 %
 %    Example:
 %
 %    TestDataSet = prtDataGenUnimodal;       % Create some test and
 %    TrainingDataSet = prtDataGenUnimodal;   % training data
 %    classifier = prtClassMap;               % Create a classifier
 %    classifier = classifier.train(TrainingDataSet);    % Train
 %    classified = run(classifier, TestDataSet);         % Test
 %
 %    subplot(2,1,1); classifier.plot;  % Plot results
 %    subplot(2,1,2); prtScoreRoc(classified,TestDataSet);
 %    set(get(gca,'Children'), 'LineWidth',3) 
 %
 %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
 %    prtClassMap, prtClassFld, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
 %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClassSvm,
 %    prtClassTreeBaggingCap, prtClassKmsd, prtClassKnn                   

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
        % Required by prtAction
        name = 'Maximum a Posteriori Log'   % Maximum a Posteriori
        nameAbbreviation = 'MAPLog'        % MAP
        isNativeMary = true;            % True
    end
    
    properties
        rvs = prtRvMvn; % Random variable object containing mean and variance
    end
    
    methods
        % Constructor
        function Obj = prtClassMapLog(varargin)
            
            Obj.classTrain = 'prtDataInterfaceCategoricalTargets';
            Obj.classRun = 'prtDataSetBase';
            Obj.classRunRetained = false;
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        % Set function
        function Obj = set.rvs(Obj,val)
            if ~(isa(val, 'prtRv') || isa(val, 'prtBrv')) 
                error('prtClassMapLog:rvs','Rvs parameter must be of class prtRv');
            else
                Obj.rvs = val;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            % Repmat the rv objects to get one for each class
            Obj.rvs = repmat(Obj.rvs(:), (DataSet.nClasses - length(Obj.rvs)+1),1);
            Obj.rvs = Obj.rvs(1:DataSet.nClasses);

            % Get the ML estimates of the RV parameters for each class
            for iY = 1:DataSet.nClasses
                Obj.rvs(iY) = train(Obj.rvs(iY), DataSet.retainClassesByInd(iY));
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            logLikelihoods = zeros(DataSet.nObservations, length(Obj.rvs));
            for iY = 1:length(Obj.rvs)
                logLikelihoods(:,iY) = getObservations(run(Obj.rvs(iY), DataSet));
            end

            DataSet = prtDataSetClass(logLikelihoods);
        end
    
        function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
            
            xOut = zeros(size(xIn,1),length(Obj.rvs));
            for iY = 1:length(Obj.rvs)
                xOut(:,iY) = runFast(Obj.rvs(iY), xIn);
            end
            
            %xOut = exp(bsxfun(@minus, logLikelihoods, prtUtilSumExp(logLikelihoods.').'));
        end
    end
    
end
