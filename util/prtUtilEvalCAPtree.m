function Yout = prtUtilEvalCAPtree(tree,X,nClasses)
%Yout = evalCAPtree(tree,X)
%   Evaluate a CAP tree on a 1xN data point X
% Internal 
% xxx Need Help xxx







if nargin < 3 || isempty(nClasses)
    nClasses = 2;
end

index = 1;
voted = false;
while ~voted
    if any(isfinite(tree.W(:,index)))
        %disp(((tree.W(:,index)'*X(:,tree.featureIndices(:,index))')') - tree.threshold(:,index))
        Yout = double(((tree.W(:,index)'*X(:,tree.featureIndices(:,index))')' - tree.threshold(:,index)) >= 0);
        if Yout == 0
            index = find(tree.treeIndices(:) == index,1,'first');
        elseif Yout > 0
            index = find(tree.treeIndices(:) == index,1,'last');
        end
    else
        Yout = zeros(1,nClasses);
        Yout(tree.terminalVote(index)) = 1;
        voted = true;
    end
end
