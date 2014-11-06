classdef prtClassCitationKnnMultiInstance < prtClass

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
        name = 'K-Nearest Neighbor'
        nameAbbreviation = 'KNN'
        
        % Required by prtClass
        isNativeMary = false;
        
    end 
    
    properties
        % k
        %   K specifies the number of neighbors to consider in the
        %   nearest-neighbor voting.
        k = 2;
        c = 4;
        % distanceFunction
        %   Specifies a function handle taking two vector-valued inputs x1
        %   and x2 and outputing a matrix of distances of size size(x1,1) x
        %   size(x2,1).  Most prtDistance* functions are valid here. 
        distanceFunction = @(x1,x2)HausdorffDist(x1,x2);
    end
    
    methods
        function Obj = prtClassKnn(varargin)
            %Knn = prtClassKnn(varargin)
            %   The KNN constructor allows the user to use name/property 
            % pairs to set public fields of the KNN classifier.
            %
            %   For example:
            %
            %   ds = prtDataGenUnimodal;
            %   Knn = prtClassKnn;
            %   Knn = Knn.train(ds);
            %   subplot(2,1,1); plot(Knn);
            %
            %   Knn11neighbors = prtClassKnn('k',11);
            %   Knn11neighbors = Knn11neighbors.train(ds);
            %   subplot(2,1,2); plot(Knn11neighbors)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            Obj.verboseStorage = true;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function Obj = preTrainProcessing(Obj,DataSet)
            if ~Obj.verboseStorage
                warning('prtClassKnn:verboseStorage:false','prtClassKnn requires verboseStorage to be true; overriding manual settings');
            end
            Obj.verboseStorage = true;
            Obj = preTrainProcessing@prtClass(Obj,DataSet);
        end
        function Obj = trainAction(Obj,~)
            %Do nothing; we've already specified "verboseStorage = true",
            %so the ".DataSet" field will be set when it comes time to test
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            nClasses = Obj.DataSet.nClasses;
            uClasses = Obj.DataSet.uniqueClasses;
            n = PrtDataSet.nObservations;
            labels = getTargets(Obj.DataSet);
            yReference = zeros(n,nClasses);
            yCitation = zeros(n,nClasses);
            
            xTrain = getObservations(Obj.DataSet);
            xTest = getObservations(PrtDataSet);
            
            
            %reference distance mat
            for trainingInd = 1:size(xTrain,1)
                for testingInd = 1:size(xTest,1)
                    distanceMat(trainingInd,testingInd) = feval(Obj.distanceFunction,xTrain{trainingInd},xTest{testingInd});
                end
            end
            
            %citation distance mat; how close are all the training points
            %to one another
            for trainingInd1 = 1:size(xTrain,1)
                for trainingInd2 = 1:size(xTrain,1)
                    citationDistanceMat(trainingInd1,trainingInd2) = feval(Obj.distanceFunction,xTrain{trainingInd1},xTrain{trainingInd2});
                end
            end
            citationDistanceMat = citationDistanceMat + diag(inf(size(xTrain,1),1));
            
            %for each test point
            for testInd = 1:size(xTest,1)
                %distanceMat already has the distance from all the training
                %points to the test point; the full citation distances are
                %the concatenation of the training citation distances with
                %the current citation distance
                tempCitationMat = cat(1,citationDistanceMat,distanceMat(:,testInd)');
                [~,I] = sort(tempCitationMat,1,'ascend');
                
                %find training points where the test point is one of the c
                %nearest neighbors; these points "cite" the test point
                citers = I(1:Obj.c,:);
                indices = find(any(citers == size(citationDistanceMat,1)+1));
                Citers{testInd} = Obj.DataSet.getTargets(indices);
            end
            
            %references
            [~,I] = sort(distanceMat,1,'ascend');
            I = I(1:Obj.k,:);
            L = labels(I)';
            
            for class = 1:nClasses
                yReference(:,class) = sum(L == uClasses(class),2);
                for ind = 1:size(xTest,1)
                    yCitation(ind,class) = sum(Citers{ind}' == uClasses(class),2);
                end
            end
            y = yReference + yCitation;
            [Etc.nVotes,Etc.MapGuessInd] = max(y,[],2);
            Etc.MapGuess = uClasses(Etc.MapGuessInd);
            ClassifierResults = prtDataSetClass(Etc.MapGuess);
            
        end
        
    end
end
