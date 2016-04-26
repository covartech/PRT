function pos = prtPlotUtilCenterFigure(windowSize)







ss = prtPlotUtilCurrentCursorScreenSize;

% Center the window
sizePads = round((ss(3:4)-ss(1:2)+1-windowSize));
sizePads(1) = sizePads(1)/2; % We should use 2 right?
sizePads(2) = sizePads(2)/2;
pos = cat(2,sizePads+ss(1:2)-1,windowSize);
