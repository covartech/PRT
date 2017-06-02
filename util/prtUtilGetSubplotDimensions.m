function [MM,JJ] = prtUtilGetSubplotDimensions(nPlots)
%[MM,JJ] = prtUtilGetSubplotDimensions(nPlots);
% xxx Need Help xxx

if nPlots <= 3
    MM = nPlots;
    JJ = 1;
elseif nPlots == 4
    MM = 2;
    JJ = 2;
elseif nPlots <= 6
    MM = 2;
    JJ = 3;
elseif nPlots <= 8
    MM = 2;
    JJ = 4;
elseif nPlots <= 9
    MM = 3;
    JJ = 3;
else
    root = ceil(sqrt(nPlots));
    % Look for a perfect rectangle as long as we don't get TOO oblong -
    % call too oblong about 1/2 of root
    for i = root:-1:root*0.6
        if rem(nPlots,i) == 0
            MM = i;
            JJ = nPlots/i;
            return
        end
    end
    % Otherwise, make the best rectangle we can
    for i = root:-1:1
        if root*(i-1) < nPlots
            MM = i;
            JJ = root;
            return;
        end
    end
end