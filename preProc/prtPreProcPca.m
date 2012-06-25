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
    %   dataSet = prtDataGenFeatureSelection;    % Load a data set
    %   pca = prtPreProcPca;            % Create a prtPreProcPca object
    %                        
    %   pca = pca.train(dataSet);       % Train the prtPreProcPca object
    %   dataSetNew = pca.run(dataSet);  % Run
    % 
    %   % Plot
    %   plot(dataSetNew);
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
        nComponents = 3;   % The number of principle components
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
        totalPercentVarianceCumulative = []; %The perceont of the total training variance explained in totalVarianceCumulative
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
        
        function Obj = trainAction(Obj,DataSet)
                       
            Obj.means = prtUtilNanMean(DataSet.getObservations(),1);
            x = bsxfun(@minus,DataSet.getObservations(),Obj.means);
            
            maxComponents = min(size(x));
            
            if Obj.nComponents > maxComponents
                warning('prt:prtPreProcPca','User specified # PCA components (%d) is > maximum number of PCA allowed (min(size(x)) = %d)',Obj.nComponents,maxComponents);
                Obj.nComponents = maxComponents;
            end
            
            [s,u,v] = svds(x,Obj.nComponents); %#ok<ASGLU>
            
            Obj.pcaVectors = v;
            
            Obj.trainingTotalVariance = sum(var(x));
            pcaVariance = cumsum(var(x*v));
            
            Obj.totalVarianceCumulative = pcaVariance;
            Obj.totalVariance = Obj.totalVarianceCumulative(end);
            Obj.totalPercentVarianceCumulative = Obj.totalVarianceCumulative./Obj.trainingTotalVariance;
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(Obj.runActionFast(DataSet.getObservations));
        end
        
        function xOut = runActionFast(Obj,xIn)
            xOut = bsxfun(@minus,xIn,Obj.means)*Obj.pcaVectors;
        end
        
    end
end