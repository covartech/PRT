classdef prtBlockDiagram < prtBlock
    
    properties
        connectivityMatrix
        blockList
        inputList
        outputList
        actionCell
    end
    
    methods
        function prtB = prtBlockDiagram(nInputs,nOutputs,blocks)
            %How do you construct this?
            prtB.connectivityMatrix = false(4);
            prtB.connectivityMatrix(3,1) = true;  %Inputs to block
            prtB.connectivityMatrix(3,2) = true;
            prtB.connectivityMatrix(4,3) = true;  %Outputs from blo
            
            [contextDataSet,classificationDataSet] = prtDataGenContextDependent;
            
            %This creates a block diagram with sources and sinks:
            prtB.actionCell = {prtBlockSourceDataSet('dataSet',contextDataSet),prtBlockSourceDataSet('dataSet',classificationDataSet),...
                prtBlockContextDependentRvm,prtBlockSinkAssignInBase('varName','contextResults')};
        end
        
        function Obj = train(Obj)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            
            input = cell(size(Obj.connectivityMatrix,1),1);
            for i = 1:length(topoOrder)
                if ~any(Obj.connectivityMatrix(i,:))
                    currentInput = {};
                else
                    currentInput = input(Obj.connectivityMatrix(i,:));
                end
                Obj.actionCell{i} = train(Obj.actionCell{i},currentInput{:});
                %input{i} = runOnTrainingData(Obj.actionCell{i-1},currentInput{:});
                input{i} = run(Obj.actionCell{i},currentInput{:});
                
                %Fixed by having runOnTrainingData call postRunProcessing
                %input{i} = input{i}.setTargets(input{1}.getTargets);
            end
        end
        function input = run(Obj)
            
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            
            for i = 1:length(topoOrder)
                if ~any(Obj.connectivityMatrix(i,:))
                    currentInput = {};
                else
                    currentInput = input(Obj.connectivityMatrix(i,:));
                end
                input{i} = run(Obj.actionCell{i},currentInput(:));
            end
            %do nothing!  for now we return the "oinput" (i.e. output) cell
            %array, but sinks should do something clever if theyu want to
            %work in general
        end
        function varargout = drawBlock(varargin)
        end
    end
end 