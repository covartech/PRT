classdef prtPreProcPca < prtPreProc
    % prtPreProcPca   Principle Component Analysis
    %
    %   PCA = prtPreProcPca creates a Principle Component Analysis selfect.
    %
    %   PCA = prtPreProcPca('nComponents',N) constructs a
    %   prtPreProcPCP selfect PCA with nComponents set to the value N.
    %
    %   A prtPreProcPca selfect has the following properites:
    %
    %   nComponents    - The number of principle componenets
    %
    %   A prtPreProcPca selfect also inherits all properties and functions from
    %   the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenFeatureSelection;    % Load a data set
    %   pca = prtPreProcPca;            % Create a prtPreProcPca selfect
    %
    %   pca = pca.train(dataSet);       % Train the prtPreProcPca selfect
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
        name = 'Principal Component Analysis' % Principal Component Analysis
        nameAbbreviation = 'PCA'  % PCA
    end
    
    properties
        nComponents = 3;   % The number of principle components
    end
    properties
        
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
        removeMean = true;
    end
    
    methods
        
        % Allow for string, value pairs
        function self = prtPreProcPca(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods
        
        
        function dataSet = approximate(self,dataSet)
            % dataSetApp = approximate(pca,dataSet)
            %  Generate the PCA basis approximation to the data in dataSet.
            %
            dataSetScores = self.run(dataSet);
            dataSet = reconstruct(self,dataSetScores);
        end
        
        function dataSet = reconstruct(self,dataSetScores)
            % dataSetApp = reconstruct(pca,dataSetScores)
            %  Generate the PCA basis approximation using the scores in dataSetScores
            %
            
            xOut = repmat(self.means,dataSetScores.nObservations,1);
            if self.nComponents > 0
                xOut = xOut + (dataSetScores.X*self.pcaVectors');
            end
            dataSet = dataSetScores;
            dataSet.X = xOut; 
        end
        
        function self = set.nComponents(self,nComp)
            if ~isnumeric(nComp) || ~isscalar(nComp) || nComp < 0 || round(nComp) ~= nComp
                error('prt:prtPreProcPca','nComponents (%s) must be a positive scalar integer',mat2str(nComp));
            end
            self.nComponents = nComp;
        end
        
    end
    
    methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(self) %#ok<MANU>
            featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('PC Score #index#');
        end
    end
    
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,dataSet)
                 
            if self.removeMean
                self.means = prtUtilNanMean(dataSet.getObservations(),1);
            else
                self.means = zeros(1,dataSet.nFeatures);
            end
            
            if self.nComponents == 0
                return
            end
            x = bsxfun(@minus,dataSet.getObservations(),self.means);
            
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
        
        function dataSet = runAction(self,dataSet)
            dataSet.X = self.runActionFast(dataSet.getObservations);
        end
        
        function xOut = runActionFast(self,xIn)
            
            if self.nComponents == 0
                xOut = nan(size(xIn,1),1);
                return;
            end
            if self.removeMean
                xOut = bsxfun(@minus,xIn,self.means);
                if self.nComponents > 0
                    xOut = xOut*self.pcaVectors;
                end
            else
                xOut = xIn*self.pcaVectors;
            end
        end
        
    end
end
