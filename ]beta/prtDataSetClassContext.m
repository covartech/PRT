classdef prtDataSetClassContext  < prtDataSetClass

    
    properties
        contextFeatIndicator
    end

    
    % Ease of use properties and methods, perhaps these should be
    % moved to prtDataSetStandardClass
    methods
        function obj = set.contextFeatIndicator(obj,val)
            obj.contextFeatIndicator = val;
        end
        function contextFeats = getContextFeats(obj)
            xAll = obj.X;
            contextFeats = xAll(:,obj.contextFeatIndicator);
        end
        function targetFeats = getTargetFeats(obj)
            xAll = obj.X;
            targetFeats = xAll(:,~obj.contextFeatIndicator);
        end
        function dsContext = getContextDataSet(obj)
            xContext = obj.getContextFeats;
            c = obj.C;
            dsContext = prtDataSetClass(xContext,c);
        end
        function dsClass = getTargetDataSet(obj)
            xClass = obj.getTargetFeats;
            y = obj.Y;
            dsClass = prtDataSetClass(xClass,y);
        end
        function c = C(obj)
            c = cat(1,[],obj.observationInfo.contextLabel);
        end       
        
        function obj = prtDataSetClassContext(dsTarget,dsContext)
            xClass = dsTarget.X;
            xContext = dsContext.X;
            y = dsTarget.Y;
            c = dsContext.Y;
            
            obj.X = [xClass,xContext];
            obj.contextFeatIndicator = [false(1,size(xClass,2)),true(1,size(xContext,2))];
            obj.Y = y;
            if ~isempty(c)
                obj.observationInfo = repmat(struct('contextLabel',[]),dsContext.nObservations,1);
                for i = 1:dsContext.nObservations
                    obj.observationInfo(i).contextLabel = c(i);
                end
            else
                for i = 1:length(obj.observationInfo)
                    obj.observationInfo(i).contextLabel = [];
                end
            end
        end
    end
    
end
