classdef prtPreProcTsne < prtPreProc
    %prtPreProcTsne - t-Distributed Stochastic Neighbor Embedding
    %   A non-linear dimension reduction technique.
    %
    %   The t-SNE implementation relies upon the algorithm and code
    %   provided here: 
    %       http://homepage.tudelft.nl/19j49/t-SNE.html
    %
    %   This code is only licensed for non-commercial applications, so it
    %   is not distributed with the PRT.  If you want to use the t-SNE
    %   code, or this object, download the software from the above link,
    %   then run:
    %       addpath(genpath(<path-to-tsne>))
    %
    %
    %
    
    
    properties (SetAccess=private)
        name = 't-Distributed Stochastic Neighbor Embedding'
        nameAbbreviation = 'tSNE' 
    end
    
    properties (SetAccess = protected)
        
    end
    
    properties
        nDimensions = 2;
        initialDims = 30;
        perplexity = 30;
    end
    
    methods
     
               % Allow for string, value pairs
        function self = prtPreProcTsne(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            %
            
            % Do nothing
        end
        
        function dataSet = runAction(self,dataSet)
           dataSet.X = tsne(dataSet.X, [], self.nDimensions, self.initialDims, self.perplexity);
        end
    end
end
