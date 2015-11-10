classdef prtPreProcLabelVoting < prtPreProc
    % Switches labels of the training data to be the most popular label amoungst k neihbors
    % This isn't necessarily a great idea but it has been proposed by several people.
    %
    % Example:
    %
    % ds = prtDataGenXor;
    %
    % eta = 0.2;
    % flipLabel = rand(ds.nObservations,1) < eta;
    %
    % newY = ds.Y;
    % newY((ds.Y == 0) & flipLabel) = 1;
    % newY((ds.Y == 1) & flipLabel) = 0;
    %
    % dsFlippedY = ds;
    % dsFlippedY.Y = newY;
    %
    % class = train(prtClassMap('rvs',prtRvGmm('nComponents',2)), dsFlippedY);
    %
    % subplot(1,2,1)
    % plot(class)
    %
    % class = train(prtPreProcLabelVoting('k',10) + prtClassMap('rvs',prtRvGmm('nComponents',2)), dsFlippedY);
    %
    % subplot(1,2,2)
    % plot(class.actionCell{2})

    properties (SetAccess=private)
        name = 'Label Voting'  
        nameAbbreviation = 'LVNN'
    end
    properties
        k = 3;
    end
    
    methods
        function self = prtPreProcLabelVoting(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        function self = preTrainProcessing(self,DataSet)
            if ~self.verboseStorage
                warning('prtPreProcLabelVoting:verboseStorage:false','prtPreProcLabelVoting requires verboseStorage to be true; overriding manual settings');
            end
            self.verboseStorage = true;
            self = preTrainProcessing@prtPreProc(self,DataSet);
        end
        function self = trainAction(self,~)
            %Do nothing; we've already specified "verboseStorage = true",
            %so the ".dataSet" field will be set when it comes time to test
        end
        
        function ds = runActionOnTrainingData(self, ds)
            
            distanceMat = prtDistanceEuclidean(ds.X,ds.X);
            [~,I] = sort(distanceMat,1,'ascend');
            I = I(1:self.k+1,:);
            L = ds.Y(I);
            
            if self.k ~= 1
                L = L';
            end
            L = L(:,2:end); % First one is yourself...
            
            uClasses = ds.uniqueClasses;
            confOut = zeros(size(L,1), ds.nClasses);
            for iY = 1:ds.nClasses
                confOut(:,iY) = sum(L == uClasses(iY),2);
            end
            [~, classInd] = max(confOut,[],2);
            
            ds.Y = uClasses(classInd);
            
        end
        function ds = runAction(~, ds)
            % Nadda
        end
    end
end