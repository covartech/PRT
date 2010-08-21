classdef prtRegressLslr < prtRegress
    % prtRegressLslr - Least-squares linear regression object.
    %   Nomenclature taken from Hastie...
    %
    % prtRegressLslr Properties: 
    %   beta - regression weights  - estimated during training
    %   t - measure of feature importance - estimated during training
    %   rss - residual sum of squares - estimated during training
    %   standardizedResiduals - estimated during training
    %
    % prtClassKnn Methods:
    %   prtRegressLslr - Least-squares linear regression constructor
    %   train - Least-squares linear regression training; see prtAction.train
    %   run - Least-squares linear regression evaluation; see prtAction.run
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Least Squares Linear Regression'
        nameAbbreviation = 'LSLR'
        isSupervised = true;
    end
    
    properties (SetAccess = 'protected')
        
        % beta is a DataSet.nDimensions + 1 x 1 vector of regression
        % weights estimated via least-squares linear regression.  The first
        % element of beta corresponds to the DC bias weight.
        beta = [];
        % t is a measure of the importance of each of the
        % DataSet.nDimensions + 1 (DC bias) weights.  The first element of
        % t corresponds to the DC bias term.  
        t = [];
        % rss contains the residual sum of squared errors from the training
        % set.
        rss = [];
        % standardizedResiduals are standardized residuals (see Hastie...)
        standardizedResiduals = [];
    end
    
    methods
        
        function Obj = prtRegressLslr(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            x = DataSet.getObservations;
            y = DataSet.getTargets;
            
            xCentered = bsxfun(@minus,x,mean(x,1));
            yCentered = bsxfun(@minus,y,mean(y,1));
            
            Obj.beta = (xCentered'*xCentered)^(-1) * xCentered'*yCentered;
            Obj.beta = [mean(y,1) - mean(x,1)*Obj.beta;Obj.beta];
            
            z = cat(2,ones(size(xCentered,1),1),xCentered);
            
            yHat = cat(2,ones(size(x,1),1),x)*Obj.beta;
            e = yHat - y;
            Obj.rss = sum(e(:).^2);
            sigmaHat = sqrt(Obj.rss./(size(x,1) - size(x,2) - 1));
            
            if size(x,1) < 1000
                % this can be expensive to calculate
                H = z*(z'*z)^(-1)*z';
                Obj.standardizedResiduals = bsxfun(@rdivide,e,(sigmaHat*(1-diag(H)).^(1/2)));
            else
                Obj.standardizedResiduals = nan;
            end
            
            Obj.t = bsxfun(@rdivide,Obj.beta,sigmaHat*sqrt(diag((z'*z)^(-1))));
            
            Obj.standardizedResiduals = Obj.standardizedResiduals;

        end
        
        function RegressionResults = runAction(Obj,DataSet)
            x = DataSet.getObservations;
            [N,p] = size(x);
            x = cat(2,ones(N,1),x);
            RegressionResults = DataSet.setObservations(x*Obj.beta);
        end
        
    end
    
end