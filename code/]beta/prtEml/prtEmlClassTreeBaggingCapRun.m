function output = prtEmlClassTreeBaggingCapRun(inputX,prtEmlClassTreeBaggingCapStruct)
% output = prtEmlClassTreeBaggingCapRun(inputX,prtEmlClassTreeBaggingCapStruct)
% 
%   As a prtEml*Run function, prtEmlClassTreeBaggingCapRun takes individual
%   vectors of features and outputs scalar values corresponding to the
%   class estimates of the classifier.  The classifier structure should be
%   the second input.  Note that the second input is not a prtClass object.

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.



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
