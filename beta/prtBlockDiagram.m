classdef prtBlockDiagram < prtBlock
    
    properties
        connectionMatrix
        blockList
        inputList
        outputList
    end
    
    methods
        function prtB = prtBlockDiagram(nInputs,nOutputs,blocks)
            %How do you construct this?
            prtB.connectionMatrix = false(5);
            prtB.connectionMatrix(3,1) = true;  %Inputs to block
            prtB.connectionMatrix(3,2) = true;
            prtB.connectionMatrix(3,3) = true;  %Outputs from block
            prtB.connectionMatrix(4,3) = true;
        end
        
        function varargout = train(varargin)
            error('this doesn''t work');
            topoOrder = prtUtilTopographicalSort(Obj.connectivityMatrix');
            input = cell(size(Obj.connectivityMatrix,1),1);
            input{1} = DataSet;
            
            for i = 2:length(topoOrder)-1
                currentInput = catFeatures(input{Obj.connectivityMatrix(i,:)});
                Obj.actionCell{i-1} = train(Obj.actionCell{i-1},currentInput);
                input{i} = runOnTrainingData(Obj.actionCell{i-1},currentInput);
                
                %Fixed by having runOnTrainingData call postRunProcessing
                %input{i} = input{i}.setTargets(input{1}.getTargets);
            end
        end
        function run()
        end
        function varargout = drawBlock(varargin)
        end
    end
end 