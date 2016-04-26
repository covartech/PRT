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
