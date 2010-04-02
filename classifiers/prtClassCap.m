classdef prtClassCap < prtClass
    % prtClassCap - Central axis projection classifier
    %
    % prtClassCap Properties: 
    %   w - Central axis projection weights - set during training
    %   threshold - Decision threshold - set during training
    %
    % prtClassCap Methods:
    %   prtClassCap - Central axis projection constructor
    %   train - Central axis projection training; see prtAction.train
    %   run - Central axis projection evaluation; see prtAction.run
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Central Axis Projection'
        nameAbbreviation = 'CAP'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
        
        % Central axis projection weights
        w = [];
        % Decision threshold
        threshold = []; 
    end 
    
    properties
        % thresholdSampling
        %   thresholdSampling specifies the number of neighbors to consider in the
        %   nearest-neighbor voting.
        thresholdSampling = 100;
    end
    
    methods
        function Obj = prtClassCap(varargin)
            %Cap = prtClassCap(varargin)
            %   The KNN constructor allows the user to use name/property 
            % pairs to set public fields of the KNN classifier.
            %
            %   For example:
            %
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected)
        function Obj = trainAction(Obj,DataSet)
            
            x = DataSet.getObservations;
            mean0 = mean(DataSet.getObservationsByClass(0),1);
            mean1 = mean(DataSet.getObservationsByClass(1),1);
            
            Obj.w = mean1 - mean0;
            Obj.w = Obj.w./norm(Obj.w);
            CAP.Obj.w = Obj.w;
            
            y = DataSet.getTargets;
            yOut = (CAP.Obj.w*x')';
            
            if Obj.thresholdSampling > length(y)
                [pf,pd,~,thresh] = prtScoreRoc(yOut,y);
            else
                [pf,pd,~,thresh] = prtScoreRoc(yOut,y,Obj.thresholdSampling);
            end
            pE = prtUtilPfPd2Pe(pf,pd);
            [minPe,I] = min(pE);
            
            %             if length(unique(yOut >= thresh(unique(I)))) == 1
            %                 error('Possible NaNs in data in generateCAP');
            %             end
            Obj.threshold = thresh(unique(I));

        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            x = getObservations(PrtDataSet);
            
            y = (Obj.w*x')';
            y = y - Obj.threshold;
            y(y >= 0) = 1;
            y(y < 0) = 0;

            ClassifierResults = prtDataSet(y);
            
        end
        
    end
end
