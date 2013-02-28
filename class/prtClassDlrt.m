classdef prtClassDlrt < prtClass
    % prtClassDlrt  Distance likelihood ratio test classifier
    %
    %    CLASSIFIER = prtClassDlrt returns a Dlrt classifier
    %
    %    CLASSIFIER = prtClassDlrt(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassDlrt object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassDlrt object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    k                  - The number of neigbors to be considered
    %    distanceFunction   - The function to be used to compute the
    %                         distance from samples to cluster centers. 
    %                         It must be a function handle of the form:
    %                         @(x1,x2)distFun(x1,x2). Most prtDistance*
    %                         functions will work.
    %
    %    For more information on Dlrt classifiers, refer to the
    %    following paper:
    %
    %    Remus, J.J. et al., "Comparison of a distance-based likelihood ratio
    %    test and k-nearest neighbor classification methods" Machine Learning
    %    for Signal Processing, 2008. MLSP 2008. IEEE Workshop on, October,
    %    2008.
    %
    %    A prtClassDlrt object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUniModal;       % Create some test and
    %     TrainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassDlrt;              % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     subplot(2,1,1);
    %     classifier.plot;
    %     subplot(2,1,2);
    %     [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %     h = plot(pf,pd,'linewidth',3);
    %     title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassDlrt,  prtClass

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
        name = 'Distance Likelihood Ratio Test' % Distance Likelihood Ratio Test
        nameAbbreviation = 'DLRT' % DLRT
        isNativeMary = false;  % False
    end 
    
    properties
 
        k = 3;   % The number of neighbors to consider in the voting
        distanceFunction = @(x1,x2)prtDistanceEuclidean(x1,x2);   % Function handle to compute distance
    end
    
    methods
        function Obj = prtClassDlrt(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
        
        function Obj = set.k(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassDlrt:k','k must be a positive scalar integer');
            end
            Obj.k = val;
        end
        
        function Obj = set.distanceFunction(Obj,val)
            if ~isa(val,'function_handle')
                error('prt:prtClassDlrt:distanceFunction','distanceFunction must be a function handle');
            end
            Obj.distanceFunction = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        function Obj = preTrainProcessing(Obj,DataSet)
            if ~Obj.verboseStorage
                warning('prtClassDlrt:verboseStorage:false','prtClassKnn requires verboseStorage to be true; overriding manual settings');
            end
            Obj.verboseStorage = true;
            Obj = preTrainProcessing@prtClass(Obj,DataSet);
        end
        function Obj = trainAction(Obj,twiddle)
            %Do nothing; we've already specified "verboseStorage = true",
            %so the ".dataSet" field will be set when it comes time to test
            
            % Just one error check to make sure that we have enough
            % training data for our value of k
            assert(all(Obj.dataSet.nObservationsByClass >= Obj.k),'prtClassDlrt:trainAction','prtClassDlrt requires a training set with at least k observations from each class.');
        end
        
        function DataSetOut = runAction(Obj,TestDataSet)
            
            n = TestDataSet.nObservations;

            uClasses = Obj.dataSet.uniqueClasses;
            classCounts = histc(double(Obj.dataSet.getTargets),double(uClasses));
            n0 = classCounts(1);
            n1 = classCounts(2);
            
            y = zeros(n,1);
            
            memBlock = 1000;
            
            if n > memBlock
                for start = 1:memBlock:n
                    indices = start:min(start+memBlock-1,n);
                    
                    dH0 = sort(Obj.distanceFunction(Obj.dataSet.getObservationsByClassInd(1), TestDataSet.getObservations(indices)),1,'ascend');
                    dH0 = dH0(Obj.k,:)';
                    
                    dH1 = sort(Obj.distanceFunction(Obj.dataSet.getObservationsByClassInd(2), TestDataSet.getObservations(indices)),1,'ascend');
                    dH1 = dH1(Obj.k,:)';
                    
                    y(indices) = log(n0./n1) + TestDataSet.nFeatures*log(dH0./dH1);
                end
            else
                dH0 = sort(Obj.distanceFunction(Obj.dataSet.getObservationsByClassInd(1), TestDataSet.getObservations),1,'ascend');
                dH0 = dH0(Obj.k,:)';
                
                dH1 = sort(Obj.distanceFunction(Obj.dataSet.getObservationsByClassInd(2), TestDataSet.getObservations),1,'ascend');
                dH1 = dH1(Obj.k,:)';
                
                y = log(n0./n1) + TestDataSet.nFeatures*log(dH0./dH1);
            end
            
            DataSetOut = prtDataSetClass(y);
        end
        
    end
end
