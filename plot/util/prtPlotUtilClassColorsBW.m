function colors = prtPlotUtilClassColorsBW(nClasses)
% Internal function, default color specs.
% xxx Need Help xxx








% colors = [55  126 184; % Blue
%           228 26  28;  % Red
%           77  175 74;  % Green
%           255 127 0;   % Orange
%           153 153 153; % Gray
%           166 86  40;  % Brown
%           152 78  163; % Purple
%           255 255 51;  % Yello
%           247 129 191; % Pink
%           ]/255;

%255, 255, 191;
colors = [215,  25,  28;
          253, 174,  97;
          171, 221, 164;
           43, 131, 186;]/255;


% colors = gray(5);
% colors = colors(1:4,:);


colorMapInd = repmat((1:size(colors,1))',ceil(nClasses/size(colors,1)),1);
colorMapInd = colorMapInd(1:nClasses);

colors = colors(colorMapInd,:);
