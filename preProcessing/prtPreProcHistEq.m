classdef prtPreProcHistEq < prtPreProc
    % prtPreProcHistEq   Histogram equalization processing
    %
    %   ZMUV = prtPreProcHistEq creates a histogram equalization pre
    %   processing object. A prtPreProcHistEq object processes the input data
    %   so that the distribution of each feature is approximately uniform
    %   in [0,1].  
    % 
    %   prtPreProcHistEq has the following properties:
    %
    %   nSamples    - The number of samples to use when learning the
    %               histogtram of the training data.  Defaults to inf (use
    %               all the data), however for large data sets this can be
    %               slow.
    %
    %   A prtPreProcHistEq object also inherits all properties and functions from
    %   the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;     
    %   dataSet = dataSet.retainFeatures(1:2);
    %   histEq = prtPreProcHistEq;        
    %                        
    %   histEq = histEq.train(dataSet); 
    %   dataSetNew = histEq.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('HistEq Data');
    %
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Histogram Equalization'
        nameAbbreviation = 'HistEq'
        isSupervised = false;
    end
    
    properties
        nSamples = inf;
    end
    properties (SetAccess=private)
        % General Classifier Properties
        %binEdges = {};
        binEdges = [];
    end
    
    methods
        
        function Obj = prtPreProcHistEq(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            if Obj.nSamples == inf;
                Obj.nSamples = DataSet.nObservations;
                for dim = 1:DataSet.nFeatures
                    %Obj.binEdges{dim} = sort(DataSet.getX);
                    [~,Obj.binEdges] =sort(DataSet.getX);
                end
            else
                for dim = 1:DataSet.nFeatures
                    %[~,Obj.binEdges{dim}] = hist(DataSet.getFeatures(dim),Obj.nSamples);
                    [~,Obj.binEdges(:,dim)] = hist(DataSet.getObservations(:,dim),Obj.nSamples);
                end
            end
            
            Obj.binEdges = cat(1,-inf*ones(1,DataSet.nFeatures),Obj.binEdges);
            Obj.binEdges(end+1,:) = inf;
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = zeros(DataSet.nObservations,DataSet.nFeatures);
            for index = 1:DataSet.nObservations
                [ii,jj] = find(bsxfun(@gt,DataSet.getObservations(index,:),Obj.binEdges));
                [~,i] = unique(jj);
                ii = ii(i);
                X(index,:) = ii';
            end
            X = X./(size(Obj.binEdges,1)-2);  %-2, one for first, and one for last bin
            DataSet = DataSet.setObservations(X);
        end
        
    end
    
end