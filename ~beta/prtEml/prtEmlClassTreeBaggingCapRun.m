function output = prtEmlClassTreeBaggingCapRun(inputX,prtEmlClassTreeBaggingCapStruct)
% output = prtEmlClassTreeBaggingCapRun(inputX,prtEmlClassTreeBaggingCapStruct)
% 
%   As a prtEml*Run function, prtEmlClassTreeBaggingCapRun takes individual
%   vectors of features and outputs scalar values corresponding to the
%   class estimates of the classifier.  The classifier structure should be
%   the second input.  Note that the second input is not a prtClass object.

%#eml
internalX = inputX(:);
internalOutput = zeros(1,prtEmlClassTreeBaggingCapStruct.dataSetSummary.nClasses);

provideOnlyOneOutput = prtEmlClassTreeBaggingCapStruct.dataSetSummary.nClasses==2 && prtEmlClassTreeBaggingCapStruct.twoClassParadigm(1)=='b';

for treeIndex = 1:prtEmlClassTreeBaggingCapStruct.nTrees
    tree = prtEmlClassTreeBaggingCapStruct.root(treeIndex);
    index = 1;
    voted = false;
    
    while ~voted
        if any(isfinite(tree.W(:,index))) % non-Inf W's are non-leaf nodes
            
            % Feature weights at this node
            currentW = tree.W(:,index);
            
            % Random features used at this node
            currentX = internalX(tree.featureIndices(:,index)); 
            
            % Threshold at this node
            currentThreshold = tree.threshold(index);
            
            % Binary decision at current node
            yOut = double(currentW'*currentX - currentThreshold >= 0);
            
            if all(yOut == 0) % Left - Figure out where to go next

                %find(tree.treeIndices == index,1,'first');
                % Can't use find in eml.
                for i = 1:length(tree.treeIndices)
                    if all(tree.treeIndices(i) == index)
                        index = i;
                        break;
                    end
                end
                
            else % Right - Figure out where to go next
                
                %find(tree.treeIndices == index,1,'last');
                % Can't use find in eml.
                for i = length(tree.treeIndices):-1:1
                    if all(tree.treeIndices(i) == index)
                        index = i;
                        break;
                    end
                end
                
            end
        else % If these W's are all Inf this is a terminal node
            
            internalOutput(tree.terminalVote(index)) = internalOutput(tree.terminalVote(index)) + 1;
            voted = true;
        end
    end
end

internalOutput = internalOutput/prtEmlClassTreeBaggingCapStruct.nTrees;

% if provideOnlyOneOutput
    output = internalOutput(2); % Only output the class 1 confidence
% else
%     output = internalOutput;
% end
