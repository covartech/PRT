function [colors,names] = prtPlotUtilClassColors(nClasses)
% Internal function, default color specs.
% xxx Need Help xxx







% cmap = prtPlotUtilClassColors(50); image(cat(3,cmap(:,1)',cmap(:,2)',cmap(:,3)'))

colors = [55  126 184; % Blue
          228 26  28;  % Red
          77  175 74;  % Green
          255 127 0;   % Orange % Gray removed to be reserved for unlabeled data 153 153 153; % Gray
          166 86  40;  % Brown
          152 78  163; % Purple
          255 255 51;  % Yellow
          247 129 191; % Pink
          ]/255;
      
extentedColors = [141 211 199; % 255 255 179; 190 186 218;
                  251 128 114;
                  128 177 211;
                  253 180 98;
                  179 222 105; % 252 205 229; 217 217 217;
                  188 128 189; % 204 235 197; 255 237 111;
                  ]/255;
              
colors = cat(1,colors,extentedColors);

colorMapInd = repmat((1:size(colors,1))',ceil(nClasses/size(colors,1)),1);
colorMapInd = colorMapInd(1:nClasses);

colors = colors(colorMapInd,:);

if nargout > 1
    
names = {'Blue';
         'Red';
         'Green';
         'Orange';
         'Brown';
         'Purple';
         'Yellow';
         'Pink';
         'Teal';
         'Salmon';
         'Baby Blue';
         'Peach';
         'Sea Green';
         'Light Purple';};

names = names(colorMapInd);
end
