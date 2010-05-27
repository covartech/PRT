classdef prtPreProcPca < prtPreProc
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Principal Component Analysis'
        nameAbbreviation = 'PCA'
        isSupervised = false;
    end
    
    properties
        nComponents = 3;
    end
    properties (SetAccess=private)
        % General Classifier Properties
        means = []; 
        pcaVectors = [];
    end
    
    methods
        
        function Obj = prtPreProcZmuv(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            
            %NOTE: I think we can replace all this with one call to svds
            nSamplesEmThreshold = 1000;
            
            
            Obj.means = nanmean(DataSet.getObservations(),1);
            x = bsxfun(@minus,DataSet.getObservations(),Obj.means);
            
            maxComponents = min(size(x));
            
            if Obj.nComponents > maxComponents
                Obj.nComponents = maxComponents;
            end
            
            % We no longer divide by the STD of each column to match princomp
            % 30-Jun-2009 14:05:20    KDM
            useHD = size(x,2) > size(x,1);
            
            if useHD
                useEM = size(x,1) > nSamplesEmThreshold;
            else
                useEM = false;
            end
            
            %Figure out whether to use regular, HD, or EM PCA:
            if useHD
                if useEM
                    [~, Obj.pcaVectors] = prtUtilPcaEm(x,Obj.nComponents);
                else
                    [~, Obj.pcaVectors] = prtUtilPcaHd(x,Obj.nComponents);
                end
            else
                Obj.pcaVectors = prtUtilPca(x,Obj.nComponents);
            end
            
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            X = DataSet.getObservations;
            X = bsxfun(@minus,X,Obj.means);
            DataSet = DataSet.setObservations(X*Obj.pcaVectors);
        end
        
    end
    
end