classdef prtRvMultinomial < prtRv
    properties
        probabilities
    end
    
    properties (Hidden = true, Dependent = true)
        nCategories
        isPlottable
        isValid
        plotLimits
        displayName
    end
    
    properties (Hidden = true)
        approximatelyEqualThreshold = 1e-4;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = multinomial(varargin)
            switch nargin
                case 0
                    % Supply the default object
                case 1
                    in1 = varargin{1};
                    R = multinomial;
                    if size(in1,1) == 1 && abs(sum(in1)-1) < R.approximatelyEqualThreshold
                        % R = rv.multinomial(probabilities);
                        R.probabilities = in1;
                    else
                        % R = rv.multinomial(trainingData);
                        R = mle(R,in1);
                    end
                otherwise
                    error('Invalid number of input arguments')
            end % switch nargin
        end % function rv.multinomial
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = set.probabilities(R,probs)
            assert(abs(sum(probs)-1) < R.approximatelyEqualThreshold,'Probability vector must must sum to 1!')
            R.probabilities = probs;
        end % function set.probabilities


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Actually useful methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function R = mle(R,X)
            if ~isempty(R.nCategories)
                warning('multinomial:overwrite','The probability vector has already been specified for this %s. These values have been over written and the number of categories may have changed.',R.displayName);
            end
            
            N_bar = sum(X,1);
            R.probabilities = N_bar./sum(N_bar(:));
        end % function mle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function R = weightedMle(R,X,weights)
            assert(size(weights,1)==size(X,1),'The number of weights must mach the number of observations.');            
            
            N_bar = sum(bsxfun(@times,X,weights),1);
            
            R.probabilities = N_bar./sum(N_bar(:));
        end % function weightedMle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = pdf(R,X)
            assert(R.isValid,'PDF cannot be evaluated because this RV object is not yet valid.')
            assert(size(X,2) == R.nCategories,'Incorrect dimensionality for RV object.')
            
            vals = sum(bsxfun(@times,X,R.probabilities),2);
        end % function pdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = logPdf(R,X)
            assert(R.isValid,'LOGPDF cannot be evaluated be RV object is not yet valid.')
            
            vals = log(pdf(R,X));
        end % function pdf
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function vals = draw(R,N)
            vals = mvnrnd(R.mean,R.covariance,N);
        end % function draw
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = kld(R1,R2)
            if isa(R2,'rv.multinomial')
                p = R1.probabilities;
                q = R2.probabilities;
                k = q.*(log(q)-log(p));
                k(q==0) = 0;
                val = sum(k(:));
                
            else
                error('mvn:kld','Kullback Liebler divergence can only be calculated between similar RV objects. This limitation may be removed in a future relesase.')
            end
        end % function kld
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.isValid(R)
            val = ~isempty(R.probabilities);
        end % function get.isValid
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.isPlottable(R)
            val = ~isempty(R.nDimensions) && R.nDimensions < 4 && R.isValid;
        end % function get.isPlottable
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.nCategories(R)
            if ~isempty(R.probabilities)
                val = length(R.probabilities);
            else
                val = [];
            end
        end % function get.nDimensions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.plotLimits(R)
            if R.isValid
                val = [0.5 0.5+R.nCategoSries];
            else
                error('multinomial:plotLimits','Plotting limits can no be determined for this RV because it is not yet valid.')
            end
        end % function get.plotLimits
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function display(R)
            if numel(R) == 1
                display(struct('probabilities',R.probabilities))
            else
                display@rv.rv(R,inputname(1));
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function val = get.displayName(R) %#ok
            val = 'Multinomial Random Variable';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end % methods
end % classdef