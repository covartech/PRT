classdef prtClassKnn < prtClass
    % prtClassKnn  K-nearest neighbors classifier
    %
    %    CLASSIFIER = prtClassKnn returns a K-nearest neighbors classifier
    %
    %    CLASSIFIER = prtClassKnn(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassKnn object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassKnn object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    k                  - The number of neigbors to be considered
    %    distanceFunction   - The function to be used to compute the
    %                         distance from samples to cluster centers. 
    %                         It must be a function handle of the form:
    %                         @(x1,x2)distFun(x1,x2). Most prtDistance*
    %                         functions will work.
    %
    %    For information on the  K-nearest neighbors classifier algorithm, please
    %    refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/K-nearest_neighbor_algorithm    
    %
    %    A prtClassKnn object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtClass.
    %
    %    Example:
    %
    %     TestDataSet = prtDataGenUnimodal;      % Create some test and 
    %     TrainingDataSet = prtDataGenUnimodal;  % training data
    %     classifier = prtClassKnn;           % Create a classifier
    %     classifier = classifier.train(TrainingDataSet);    % Train
    %     classified = run(classifier, TestDataSet);         % Test
    %     classifier.plot;
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassPlsda, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass

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
       
        name = 'K-Nearest Neighbor'   % K-Nearest Neighbor
        nameAbbreviation = 'KNN'      % KNN  
        isNativeMary = true;          % true
        
    end
    
    properties
      
        k = 3;   % The number of neighbors to consider in the voting
        
        distanceFunction = @(x1,x2)prtDistanceEuclidean(x1,x2);   % Function handle to compute distance
    end
    
    methods
        function Obj = prtClassKnn(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
        function Obj = set.k(Obj,val)
            if ~prtUtilIsPositiveScalarInteger(val)
                error('prt:prtClassKnn:k','k must be a positive scalar integer');
            end
            Obj.k = val;
        end
        
        function Obj = set.distanceFunction(Obj,val)
            if ~isa(val,'function_handle')
                error('prt:prtClassKnn:distanceFunction','distanceFunction must be a function handle');
            end
            Obj.distanceFunction = val;
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
        function Obj = trainAction(Obj,twiddle)
            %Do nothing; we've already specified "verboseStorage = true",
            %so the ".dataSet" field will be set when it comes time to test
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            x = getObservations(PrtDataSet);
            n = PrtDataSet.nObservations;
            
            nClasses = Obj.dataSet.nClasses;
            uClasses = Obj.dataSet.uniqueClasses;
            labels = getTargets(Obj.dataSet);
            y = zeros(n,nClasses);
            
            xTrain = getObservations(Obj.dataSet);
            
            largestMatrixSize = prtOptionsGet('prtOptionsComputation','largestMatrixSize');
            memBlock = max(floor(largestMatrixSize/size(xTrain,1)),1);
            
            if n > memBlock
                for start = 1:memBlock:n
                    indices = start:min(start+memBlock-1,n);
                    
                    distanceMat = feval(Obj.distanceFunction,xTrain,x(indices,:));
                    
                    [twiddle,I] = sort(distanceMat,1,'ascend');
                    I = I(1:Obj.k,:);
                    L = labels(I);
                    
                    % MATLAB indexing is inexplicably different if I is
                    % 1xN or (k>1)xN
                    if Obj.k ~= 1
                        L = L';
                    end
                    
                    for class = 1:nClasses
                        y(indices,class) = sum(L == uClasses(class),2);
                    end
                end
            else
                distanceMat = feval(Obj.distanceFunction,xTrain,x);
                
                [twiddle,I] = sort(distanceMat,1,'ascend');
                I = I(1:Obj.k,:);
                L = labels(I);
                
                % MATLAB indexing is inexplicably different if I is
                % 1xN or (k>1)xN
                if Obj.k ~= 1
                    L = L';
                end
                
                for class = 1:nClasses
                    y(:,class) = sum(L == uClasses(class),2);
                end
            end
            
            [Etc.nVotes,Etc.MapGuessInd] = max(y,[],2);
            Etc.MapGuess = uClasses(Etc.MapGuessInd);
            ClassifierResults = PrtDataSet;
            ClassifierResults.X = y;
            
        end
        
    end
end
