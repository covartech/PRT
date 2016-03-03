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

% Copyright (c) 2014 CoVar Applied Technologies
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
           if self.initialDims > dataSet.nFeatures
               self.initialDims = dataSet.nFeatures;
           end
           dataSet.X = tsne(dataSet.X, [], self.nDimensions, self.initialDims, self.perplexity);
        end
    end
end
