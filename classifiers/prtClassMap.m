classdef prtClassMap < prtClass
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Maximum a Posteriori'
        nameAbbreviation = 'MAP'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = true;
    end
    
    properties
        % General Classifier Properties
        rvs = prtRvMvn; % prtRv Objects (will be repmated as needed)
    end
    
    methods
        
        function Obj = prtClassMap(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            % Repmat the rv objects to get one for each class
            Obj.rvs = repmat(Obj.rvs(:), (DataSet.nClasses - length(Obj.rvs)+1),1);
            Obj.rvs = Obj.rvs(1:DataSet.nClasses);

            % Get the ML estimates of the RV parameters for each class
            for iY = 1:DataSet.nClasses
                Obj.rvs(iY) = mle(Obj.rvs(iY), DataSet.getObservationsByClassInd(iY));
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            logLikelihoods = zeros(DataSet.nObservations, length(Obj.rvs));
            for iY = 1:length(Obj.rvs)
                logLikelihoods(:,iY) = logPdf(Obj.rvs(iY), DataSet.getObservations());
            end

            % Change to posterior probabilities and package everything up in a
            % prtDataSet
            DataSet = prtDataSet(exp(bsxfun(@minus, logLikelihoods, prtUtilSumExp(logLikelihoods.').')));
            DataSet.UserData.logLikelihoods = logLikelihoods;
        end
        
    end
    
end