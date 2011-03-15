classdef prtPreProcPca < prtPreProc
    % prtPreProcPca   Principle Component Analysis
    %
    %   PCA = prtPreProcPca creates a Principle Component Analysis object.
    %
    %   PCA = prtPreProcPca('nComponents',N) constructs a
    %   prtPreProcPCP object PCA with nComponents set to the value N.
    %
    %   A prtPreProcPca object has the following properites:
    % 
    %   nComponents    - The number of principle componenets
    %
    %   A prtPreProcPca object also inherits all properties and functions from
    %   the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenUnimodal;   % Load a data set
    %   pca = prtPreProcPca;            % Create a prtPreProcPca object
    %                        
    %   pca = pca.train(dataSet);       % Train the prtPreProcPca object
    %   dataSetNew = pca.run(dataSet);  % Run
    % 
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('PCA Projected Data');
    %
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows    
    
    properties (SetAccess=private)
        name = 'Principal Component Analysis' % Principal Component Analysis
        nameAbbreviation = 'PCA'  % PCA
    end
    
    properties
        nComponents = 3;   % The number of PCA components
    end
    properties (SetAccess=private)

        means = [];           % A vector of the means
        pcaVectors = [];      % The PCA vectors.
      
        trainingTotalVariance = []; % The total variance contained in the
                                    % training data
        totalVariance = []; % The variance contained in the reduced
                            % dimension data.
        totalVarianceCumulative = []; % The variance contained in the
                                      % reduced dimension data as a
                                      % function of the number of
                                      % components
        
        
    end
    
    properties( SetAccess = private, Hidden = true)
          pcaVectorsSvd = [];
    end
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcPca(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods
        function Obj = set.nComponents(Obj,nComp)
            if ~isnumeric(nComp) || ~isscalar(nComp) || nComp < 1 || round(nComp) ~= nComp
                error('prt:prtPreProcPca','nComponents (%s) must be a positive scalar integer',mat2str(nComp));
            end
            Obj.nComponents = nComp;
        end
    end
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames) %#ok<MANU>
            for i = 1:length(featureNames)
                featureNames{i} = sprintf('PC Score %d',i);
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        %NOTE: I think we can replace all this with one call to svds
        function Obj = trainAction(Obj,DataSet)
                       
            nSamplesEmThreshold = 1000;
                       
            Obj.means = prtUtilNanMean(DataSet.getObservations(),1);
            x = bsxfun(@minus,DataSet.getObservations(),Obj.means);
            
            maxComponents = min(size(x));
            
            if Obj.nComponents > maxComponents
                warning('prt:prtPreProcPca','User specified # PCA components (%d) is > number of data dimensions (%d)',Obj.nComponents,maxComponents);
                Obj.nComponents = maxComponents;
            end
            
            % We no longer divide by the STD of each column to match princomp
            % 30-Jun-2009 14:05:20    KDM
            useHD = size(x,2) > size(x,1);
            
            if useHD
                useEM = size(x,1) > nSamplesEmThreshold;
            else
                useEM = false;
            end
            
            %Figure out whether to use regular, HD, or EM PCA:
            if useHD
                if useEM
                    [twiddle, Obj.pcaVectors] = prtUtilPcaEm(x,Obj.nComponents); %#ok<ASGLU>
                else
                    [twiddle, Obj.pcaVectors] = prtUtilPcaHd(x,Obj.nComponents); %#ok<ASGLU>
                end
            else
                Obj.pcaVectors = prtUtilPca(x,Obj.nComponents);
            end
            
            Obj.trainingTotalVariance = sum(var(x));
            pcaVariance = cumsum(var(x*Obj.pcaVectors));
            
            Obj.totalVarianceCumulative = pcaVariance;
            Obj.totalVariance = Obj.totalVarianceCumulative(end);
            
            %For debugging: if you want to compare to SVD decomposition.
            %SVD is marginally faster for smaller matrices, but EM and HD
            %are better for larger matrices.  We use the right ones at the
            %right times.  SVD and PCA should give about the same PC's - V
            %should be ~= Obj.pcaVectors
            %             disp('svd')
            %             tic;
            %             [S,U,V] = svd(x,0);
            %             Obj.pcaVectorsSvd = V(:,1:Obj.nComponents);
            %             toc;
                
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = DataSet.getObservations;
            X = bsxfun(@minus,X,Obj.means);
            DataSet = DataSet.setObservations(X*Obj.pcaVectors);
        end
        
    end
    
end