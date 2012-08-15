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
    
    properties (Hidden)
        percentVarianceToAccountFor = 0; %Hidden property; [0 - 1];
    end
    
    methods
        
          % Allow for string, value pairs
        function self = prtPreProcPca(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods
        function self = set.nComponents(self,nComp)
            %
            
            %Allows percent nComps
            if isnumeric(nComp) && isscalar(nComp) && nComp < 1 && nComp> 0
                self.nComponents = nComp;
                return
            end
            if ~isnumeric(nComp) || ~isscalar(nComp) || nComp < 1 || round(nComp) ~= nComp
                error('prt:prtPreProcPca','nComponents (%s) must be a positive scalar integer',mat2str(nComp));
            end
            self.nComponents = nComp;
        end
    end
    
    methods (Hidden = true)
        function featureNames = updateFeatureNames(obj,featureNames) %#ok<MANU>
            for i = 1:length(featureNames)
                featureNames{i} = sprintf('PC Score %d',i);
            end
        end
        
        function self = optimizeNumComponents(self,ds,percentThreshold)
            
            maxComponents = min([ds.nObservations,ds.nFeatures]);
            if nargin < 3                
                percentThreshold = self.nComponents;
            end
            
            n = maxComponents;
            self.nComponents = n;
            self = self.train(ds);
            correctN = find(self.totalPercentVarianceCumulative(:) > percentThreshold,1,'first');
            
            self.nComponents = correctN;
            
            self.means = self.means(1:correctN);
            self.pcaVectors = self.pcaVectors(:,1:correctN);
            
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function self = trainAction(self,DataSet)
                       
            if self.nComponents < 1 
                self = self.optimizeNumComponents(DataSet,self.nComponents);
            end
            
            self.means = prtUtilNanMean(DataSet.getObservations(),1);
            x = bsxfun(@minus,DataSet.getObservations(),self.means);
            
            maxComponents = min(size(x));
            if self.nComponents > maxComponents
                warning('prt:prtPreProcPca','User specified # PCA components (%d) is > maximum number of PCA allowed (min(size(dataSet.data)) = %d)',self.nComponents,maxComponents);
                self.nComponents = maxComponents;
            end
            
            [s,u,v] = svds(x,self.nComponents); %#ok<ASGLU>
            
            self.pcaVectors = v;
            
            self.trainingTotalVariance = sum(var(x));
            pcaVariance = cumsum(var(x*v));
            
            self.totalVarianceCumulative = pcaVariance;
            self.totalVariance = self.totalVarianceCumulative(end);
            self.totalPercentVarianceCumulative = self.totalVarianceCumulative./self.trainingTotalVariance;
        end
        
        function DataSet = runAction(self,DataSet)
            DataSet = DataSet.setObservations(self.runActionFast(DataSet.getObservations));
        end
        
        function xOut = runActionFast(self,xIn)
            xOut = bsxfun(@minus,xIn,self.means)*self.pcaVectors;
        end
        
    end
end