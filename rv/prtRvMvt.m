% PRTRVMVT  PRT Random Variable Object - Multi-Variate Student T
%
% Syntax:
%   R = prt.rv.mvt
%   R = prt.rv.mvt(covarianceStructure)
%   R = prt.rv.mvt(mu,Sigma,dof)
%   R = prt.rv.mvt(mu,Sigma,dof,covarianceStructure)
%
% Methods:
%   pdf
%   logPdf    
%
% Inherited Methods
%   ezPdfPlot
%   ezCdfPlot


classdef mvt < prt.rv.rv
    properties
        covarianceStructure = 'full';
        mean
        covariance
        degreesOfFreedom
    end
    
    properties (Hidden = true, Dependent = true)
        nDimensions
        isPlottable
        isValid
        plotLimits
    end 

    properties (SetAccess = 'private', Hidden = true)
        covarianceCholDecomp
        trueCovariance
    end % properties (SetAccess = private)

    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = mvt(varargin)
            switch nargin
                case 0
                    % Supply the default object
                case 1
                    % R = prt.rv.mvt(covarianceStructure);
                    R.covarianceStructure = varargin{1};
                case 3
                    % R = prt.rv.mvt(mu,Sigma,degreesOfFreedom)
                    R.mean = varargin{1}(:)';
                    R.covariance = varargin{2};
                    R.degreesOfFreedom = varargin{3};
                case 4
                    % R = prt.rv.mvt(mu,Sigma,covarianceStructure)
                    R.mean = varargin{1}(:)';
                    R.covariance = varargin{2};
                    R.degreesOfFreedom = varargin{3};
                    R.covarianceStructure = varargin{4};
                otherwise
                    error('Invalide Number of input arguments')
            end % switch nargin
        end % function prt.rv.mvt
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = set.covarianceStructure(R,covarianceStructure)
            % Limit the options for the covariance structure
            if ~(strcmpi(covarianceStructure,'full') || ...
                    strcmpi(covarianceStructure,'diagonal') || ...
                    strcmpi(covarianceStructure,'spherical'))
                error('%s is not a valid covariance structure. Possible types are, full, diagonal, and spherical',covarianceStructure);
            end
            R.covarianceStructure = covarianceStructure;

            % Redo the covariance to reflect the updated covarianceStructure
            if ~isempty(R.covariance)
                R.covariance = R.trueCovariance;
            end
        end % function set.covarianceStructure
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = set.mean(R,meanVal)
            if ~isempty(R.covariance) && size(meanVal,2) ~= size(R.covariance,2)
                error('mvt:dimensions','Dimensions mismatch between supplied mean and rv.mvt dimensionality');
            end
            R.mean = meanVal;
        end % function set.mean
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = set.covariance(R,covariance)
            if size(covariance,1) ~= size(covariance,2)
                error('Covariance matrix must be square.')
            end

            if ~isempty(R.mean) && size(covariance,1) ~= R.nDimensions
                error('Dimensions mismatch between covariance and dprtRV dimensionality')
            end

            [cholCovR, posDefError] = cholcov(covariance,0); %#ok
            if posDefError ~= 0
                error('Covariance matrix must be positive definite.')
            end

            % Save this input as a true hidden covariance
            R.trueCovariance = covariance;

            % Enforce the covariance structure
            switch R.covarianceStructure
                case 'full'
                    R.covariance = covariance;
                case 'diagonal'
                    R.covariance = eye(size(covariance)).*covariance;
                case 'spherical'
                    R.covariance = eye(size(covariance))*mean(diag(covariance)); %#ok
            end

            R.covarianceCholDecomp = cholcov(R.covariance,0);
             
        end % function set.covariance
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = set.degreesOfFreedom(R,dof)
            if numel(dof) > 1 || dof < 0
                error('mvt:dof','The degrees of freedom must be a positive scalar value.');
            end
            R.degreesOfFreedom = dof;
        end % function set.mean
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Actually useful methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = pdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for prt.rv.mvt object.')
            vals = exp(prt.rv.mvtLogPdf(X,R.mean,R.covariance,R.degreesOfFreedom));
        end % function pdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = logPdf(R,X)
            assert(size(X,2) == R.nDimensions,'Incorrect dimensionality for prt.rv.mvt object.')            
            vals = prt.rv.mvtLogPdf(X,R.mean,R.covariance,R.degreesOfFreedom);
        end % function logPdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.isValid(R)
            if ~isempty(R.covariance) && ~isempty(R.mean) && ~isempty(R.degreesOfFreedom)
                val = true;
            end
        end % function get.isValid
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.isPlottable(R)
            if R.nDimensions < 4 && R.isValid
                val = true;
            end
        end % function get.isPlottable
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.nDimensions(R)
            if ~isempty(R.mean)
                val = length(R.mean);
            elseif ~isempty(R.covariance)
                val = size(R.covariance,2);
            else
                val = [];
            end
        end % function get.nDimensions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.plotLimits(R)
            if R.isValid
                minX = min(R.mean, [], 1)' - 2*sqrt(diag(R.covariance));
                maxX = max(R.mean, [], 1)' + 2*sqrt(diag(R.covariance));
                
                val = zeros(1,2*R.nDimensions);
                val(1:2:R.nDimensions*2-1) = minX;
                val(2:2:R.nDimensions*2) = maxX;
            else
                error('mvt:plotLimits','Plotting limits can no be determined for this rv.mvt because it is not yet valid.')
            end
        end % function plotLimits
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function varargout = ezPdfPlot(R,varargin)
            
            if length(varargin) < 1
                plotLimits = R.plotLimits;
            else
                plotLimits = varargin{1};
            end
            
            [varargout{1:nargout}] = ezPdfPlot@prt.rv.rv(R,plotLimits);
        end % function ezPdfPlot
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function varargout = ezCdfPlot(R,varargin)
            if length(varargin) < 1
                plotLimits = R.plotLimits;
            else
                plotLimits = varargin{1};
            end
            
            [varargout{1:nargout}] = ezCdfPlot@prt.rv.rv(R,plotLimits);
        end % function ezCdfPlot
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end % methods
end % classdef

