classdef prtPreProcPca < prtPreProc
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Principal Components Analysis'
        nameAbbreviation = 'PCA'
        isSupervised = false;
    end
    
    properties (SetAccess=private)
        % General Classifier Properties
        means = [];
        vectors = [];
    end
    
    properties
        % Setable Properties
        nComponents = 3;
        
        nSamplesEmThreshold = 1000; % If more than 1000 samples in the minumum dimension use EM
        
        
    end
    
    methods
        
        function Obj = prtPreProcPca(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.means = nanmean(DataSet.getObservations(),1);
            
            
            maxComponents = min([DataSet.nObservations, DataSet.nFeatures]);

            if Obj.nComponents > maxComponents
                Obj.nComponents = maxComponents;
            end
    
            X = bsxfun(@minus,DataSet.getObservations(), Obj.means);
            % We no longer divide by the STD of each column to match princomp
            % 30-Jun-2009 14:05:20    KDM
    
            useHD = size(X,2) > size(X,1);
    
            if useHD
                useEM = size(X,1) > Obj.nSamplesEmThreshold;
            else
                useEM = false;
            end

            %Figure out whether to use regular, HD, or EM PCA:
            if useHD
                if useEM
                    [~, Obj.vectors] = prtUtilPcaEm(X,Obj.nComponents);
                else
                    [~, Obj.vectors] = prtUtilPcaHd(X,Obj.nComponents);
                end
            else
                Obj.vectors = prtUtilPca(X,Obj.nComponents);
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            X = bsxfun(@minus,DataSet.getObservations(),Obj.means);
            DataSet = DataSet.setObservations(X*Obj.vectors);
        end
        
    end
    
end