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
    % make the best rectangle we can
    root = ceil(sqrt(nPlots));
    for i = root:-1:1;
        if root*(i-1) < nPlots;
            MM = i;
            JJ = root;
            return;
        end
    end
end
% elseif nPlots <= 12
%     MM = 3;
%     JJ = 4;
% elseif nPlots <= 15
%     MM = 5;
%     JJ = 3;    
% elseif nPlots <= 16
%     MM = 4;
%     JJ = 4; 
% elseif nPlots <= 25
%     MM = 5;
%     JJ = 5; 
% elseif nPlots <= 36
%     MM = 6;
%     JJ = 6;
% elseif nPlots <= 45
%     MM = 9;
%     JJ = 5;
% elseif nPlots <= 50
%     MM = 10;
%     JJ = 5;
% elseif nPlots <= 100
%     MM = 10;
%     JJ = 10;
% elseif nPlots <= 200
%     MM = 10;
%     JJ = 20;
% else 
%     warning('Nplots too large');
%     MM = inf;
%     JJ = inf;
% end
   
    
    
