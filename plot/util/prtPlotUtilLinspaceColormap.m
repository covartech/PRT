function cm = prtPlotUtilLinspaceColormap(startRGB,endRGB,len)
% Internal function, 
% xxx Need Help xxx
% prtPlotUtilLinspaceColormap makes a linearspace colormap in RGB space
%
% Syntax: cm = prtPlotUtilLinspaceColormap(startRGB,endRGB,len)







if nargin < 3
    len = 128;
end

cm = zeros(len,3);
for iRgb = 1:3
    cm(:,iRgb) = linspace(startRGB(iRgb),endRGB(iRgb),len)';
end
