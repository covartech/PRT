classdef prtClassCorrelation < prtClass
    % prtClassCorrelation  Correlation classifier
    %
    %    CLASSIFIER = prtClassCorrelation returns a correlation classifier
    %
    %    CLASSIFIER = prtClassCorrelation(PROPERTY1, VALUE1, ...)
    %    constructs a prtClassCorrelation object CLASSIFIER with properties
    %    as specified by PROPERTY/VALUE pairs.
    %
    %    A prtClassCorrelation object inherits all properties from the
    %    abstract class prtClass. 
    %
    %    A prtClassCorrelation object inherits the TRAIN, RUN,
    %    CROSSVALIDATE and KFOLDS methods from prtAction. It also inherits
    %    the PLOT method from prtClass.
    %
    %    Example:
    %
    %   TestDataSet = prtDataGenUnimodal;      % Create some test and 
    %   TrainingDataSet = prtDataGenUnimodal;  % training data
    %   classifier = prtClassCorrelation;           % Create a classifier
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassKnn, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass

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
        name = 'Correlation Classifier'
        nameAbbreviation = 'CORR'
        isNativeMary = true;
    end
    
    properties
        useMeanLibrary = false;
    end
    properties (SetAccess=protected)
        xMeans
        
    end
    
    methods
        function Obj = prtClassCorrelation(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        function Obj = preTrainProcessing(Obj,DataSet)
            if ~Obj.verboseStorage
                warning('prtClassKnn:verboseStorage:false','prtClassKnn requires verboseStorage to be true; overriding manual settings');
            end
            Obj.verboseStorage = true;
            Obj = preTrainProcessing@prtClass(Obj,DataSet);
        end
        
        function Obj = trainAction(Obj,DataSet)
                                    
            Obj.xMeans = mean(DataSet.getObservations);
            
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = DataSet.X;
            X = bsxfun(@minus,X,Obj.xMeans);
            isOneDimension = (size(X,2) == 1);
             
            Yout = zeros(size(X,1),Obj.dataSetSummary.nClasses);

            for iClass = 1:Obj.dataSetSummary.nClasses
                if Obj.useMeanLibrary
                    cTrainingX = mean(Obj.dataSet.getObservationsByClassInd(iClass),1);
                else
                    cTrainingX = Obj.dataSet.getObservationsByClassInd(iClass);
                end
                 
                cTrainingX = bsxfun(@minus, cTrainingX, Obj.xMeans);
                 
                if isOneDimension
                     cCorrMat = cTrainingX *X';
                else
                     cCorrMat = cTrainingX *X'./((sum(cTrainingX .^2,2).^.5)*(sum(X.^2,2).^.5)');
                end
                 
                Yout(:,iClass) = max(cCorrMat,[],1);
             end
             
             
            Yout = (Yout+1)/2; % Make things be between 0 and 1;
            Yout(Yout>1) = 1;
            Yout(Yout<0) = 0;

            DataSet = DataSet.setObservations(Yout);
        end

    end
end
