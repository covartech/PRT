classdef prtClassGlrt < prtClass
    % prtClassGlrt - Generalized likelihood ratio classification
    % object.
    %
    % prtClassGlrt Properties: 
    %   k - number of neighbors to consider
    %   distanceFunction - function handle specifying distance metric
    %
    % prtClassGlrt Methods:
    %   prtClassGlrt - Logistic Discrminant constructor
    %   train - Generalized likelihood ratio training; see prtAction.train
    %   run - Generalized likelihood ratio evaluation; see prtAction.run
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Generalized likelihood ratio test'
        nameAbbreviation = 'GLRT'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
        
    end 
    
    properties
        % rvH0
        rvH0 = prtRvMvn;
        % rvH1
        rvH1 = prtRvMvn;
    end
    
    methods
        function Obj = prtClassGlrt(varargin)
            %Glrt = prtClassGlrt(varargin)
            %   The Glrt constructor allows the user to use name/property 
            % pairs to set public fields of the Glrt classifier.
            %
            %   For example:
            %
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            %Obj.verboseStorage = false;
        end
    end
    
    methods (Access=protected)
       
        function Obj = trainAction(Obj,DataSet)
            
            Obj.rvH0 = mle(Obj.rvH0, DataSet.getObservationsByClass(0));
            Obj.rvH1 = mle(Obj.rvH1, DataSet.getObservationsByClass(1));
            
        end
        
        function ClassifierResults = runAction(Obj,DataSet)
            
            logLikelihoodH0 = logPdf(Obj.rvH0, DataSet.getObservations());
            logLikelihoodH1 = logPdf(Obj.rvH1, DataSet.getObservations());
            ClassifierResults = prtDataSet(logLikelihoodH1 - logLikelihoodH0);
        end
        
    end
end
