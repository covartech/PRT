classdef prtPreProcZca < prtPreProc
    % prtPreProcZca ZCA Whitening Transformation
    %
    % zca = prtPreProcZca generates a zero-phase component analysis
    % (essentially a whitening) object.  ZCA is very similar to standard
    % whitening using, e.g., PCA, but without some of the rotations and
    % scaling that PCA can impart.  Unlike PCA, the resulting data has
    % approximately spherical covariance and may be easier to interpret in
    % some instances (e.g., for images).
    %
    % For more information, see
    % http://ufldl.stanford.edu/wiki/index.php/Whitening#ZCA_Whitening
    %
    % zca = prtPreProcZca(varargin) enables the inclusion of
    %   various parameter/value pairs.  
    %
    %  A prtPreProcZca object has the following properites:
    % 
    %   eps - .01 - A diagonal loading of the estimated covariance matrix
    %           to ensure positive-definite.  If you encounter errors, try
    %           increasing eps.
    % 
    %  A prtPreProcZca object also inherits all properties
    %   and functions from the prtCluster class
    %
    % Example usage:
    %    ds = prtDataGenBimodal;
    %    pca = prtPreProcPca;
    %    pca = pca.train(ds);
    %    dsPca = pca.run(ds);
    %
    %    zca = prtPreProcZca;
    %    zca = zca.train(ds);
    %    dsZca = zca.run(ds);
    % 
    %    subplot(2,1,1); 
    %    plot(dsPca); 
    %    title('PCA Whitened');
    %    subplot(2,1,2); 
    %    plot(dsZca); 
    %    title('ZCA Whitened');
    %
    % See 
    %   Learning Feature Representations with K-means, Adam Coates and
    %   Andrew Y. Ng
    % For more information

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
        name = 'Zero Centerd Whitened'
        nameAbbreviation = 'ZCA'
    end
    
    properties
        eps = .01;
    end
    
    properties (SetAccess=private)
        
        meanVec
        covMat
        eigV
        eigD
        covInv
    end
    
    methods
        
          % Allow for string, value pairs
        function self = prtPreProcZca(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        function self = trainAction(self,dataSet)
                       
            self.meanVec = prtUtilNanMean(dataSet.X,1);
            x = bsxfun(@minus,dataSet.getObservations(),self.meanVec);
            
            self.covMat = cov(x);
            [self.eigV,self.eigD] = eig(self.covMat);
            self.covInv = self.eigV*(self.eigD + self.eps*eye(size(self.eigD)))^(-1/2)*self.eigV';
        end
        
        function dataSet = runAction(self,dataSet)
            x = bsxfun(@minus,dataSet.X,self.meanVec);
            x = (self.covInv*x')';
            dataSet.X = x;
        end
    end
end
