function output = prtEmlTreeBaggingCapRun(inputX,forest)
%output = prtEmlTreeBaggingCapRun(inputX,classifier)
% 
%   As a prtEml*Run function, prtEmlTreeBaggingCapRun takes individual
%   vectors of features and outputs scalar values corresponding to the
%   class estimates of the classifier.  The classifier structure should be
%   the second input.  Note that the second input is not a prtClass object.  Instead, 

%#eml
internalX = inputX(:);
output = zeros(1);

for treeIndex = 1:length(forest)
    tree = forest(treeIndex);
    index = 1;
    voted = 0;
    yOut = 0;
    while ~voted
        
        if any(isfinite(tree.W(:,index)))
            currentW = tree.W(:,index);
            currentX = internalX(tree.featureIndices(:,index));
            currentThreshold = tree.threshold(index);
            
            yOut = double(currentW'*currentX - currentThreshold >= 0);
            if all(yOut == 0)
                %find(tree.treeIndices == index,1,'first');
                for i = 1:length(tree.treeIndices)
                    if all(tree.treeIndices(i) == index)
                        index = i;
                        break;
                    end
                end
            else
                %find(tree.treeIndices == index,1,'last');
                for i = length(tree.treeIndices):-1:1
                    if all(tree.treeIndices(i) == index)
                        index = i;
                        break;
                    end
                end
            end
        else
            yOut = tree.terminalVote(index);
            voted = 1;
        end
    end
    output = output + yOut;
end
output = output/length(forest);

% Sample initialization script, see prtClassTreeBaggingCap.export('eml')
% % function forest = initializeRf
% % 
% % temp.W = [0.72123011910129 0.950109949802458 Inf Inf 0.919861169564896 Inf Inf NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;0.692695543006551 0.311915186046416 Inf Inf 0.392244093297402 Inf Inf NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % temp.featureIndices = [3 1 NaN NaN 2 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;4 3 NaN NaN 4 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % temp.terminalVote = [NaN NaN 0 1 NaN 0 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % temp.threshold = [0.494596490268434 1.75202088990258 NaN NaN 0.233675230019882 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % temp.treeIndices = [0 1 2 2 1 5 5 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % 
% % forest = repmat(temp,2,1);
% % 
% % forest(1).W = [0.72123011910129 0.950109949802458 Inf Inf 0.919861169564896 Inf Inf NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;0.692695543006551 0.311915186046416 Inf Inf 0.392244093297402 Inf Inf NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(1).featureIndices = [3 1 NaN NaN 2 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;4 3 NaN NaN 4 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(1).terminalVote = [NaN NaN 0 1 NaN 0 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(1).threshold = [0.494596490268434 1.75202088990258 NaN NaN 0.233675230019882 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(1).treeIndices = [0 1 2 2 1 5 5 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % 
% % forest(2).W = [0.682884770379177 0.958290976718626 Inf 0.858624845129682 Inf Inf Inf NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;0.730526105203762 0.285794338536754 Inf 0.512604501858918 Inf Inf Inf NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(2).featureIndices = [3 4 NaN 2 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;1 3 NaN 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(2).terminalVote = [NaN NaN 0 NaN 0 1 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(2).threshold = [0.494596490268434 1.75202088990258 NaN NaN 0.233675230019882 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
% % forest(2).treeIndices = [0 1 2 2 4 4 1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];