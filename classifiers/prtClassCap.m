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
            
            y = DataSet.getTargets;
            x = DataSet.getObservations;
            mean0 = mean(DataSet.getObservationsByClass(0),1);
            mean1 = mean(DataSet.getObservationsByClass(1),1);
            
            Obj.w = mean1 - mean0;
            Obj.w = Obj.w./norm(Obj.w);
            
            %Evaluate the thresold using w:
            Obj = optimizeThresholdPosNeg(Obj,x,y);
        end
        
        function Obj = optimizeThresholdPosNeg(Obj,x,y)
           
            [thresholdValue,minPe] = optimizeThreshold(Obj,x,y);
            
            %It's possible that for oddly distributed data, the weight
            %vector will point in the wrong direction, yielding a ROC curve
            %that never goes above the chance diagonal; when this happens,
            %try inverting the w vector, and re-run optimizeThreshold
            if minPe >= 0.5
                Obj.w = -Obj.w;
                [thresholdValue,minPe] = optimizeThreshold(Obj,x,y);
                if minPe >= 0.5
                    warning('Min PE from CAP.trainAction is >= 0.5');
                end
            end
            Obj.threshold = thresholdValue;
        end
        
        function [thresholdValue,minPe] = optimizeThreshold(Obj,x,y)
            yOut = (Obj.w*x')';
            
            if Obj.thresholdSampling > length(y)
                [pf,pd,~,thresh] = prtScoreRoc(yOut,y);
            else
                [pf,pd,~,thresh] = prtScoreRoc(yOut,y,Obj.thresholdSampling);
            end
            pE = prtUtilPfPd2Pe(pf,pd);
            [minPe,I] = min(pE);
            thresholdValue = thresh(unique(I));
        end
        
        function ClassifierResults = runAction(Obj,PrtDataSet)
            
            x = getObservations(PrtDataSet);
            
            y = (Obj.w*x')';
            y = y - Obj.threshold;
            y(y >= 0) = 1;
            y(y < 0) = 0;

            ClassifierResults = prtDataSetClass(y);
            
        end
        
    end
end
