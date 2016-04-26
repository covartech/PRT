function h = prtPlotUtilLinePlot(xInd,cY,linecolor,linewidth)
% Internal function, 
% xxx Need Help xxx







if isempty(xInd) || isempty(cY)
    h = nan;
    return
end
h = plot(xInd,cY,'color',linecolor,'linewidth',linewidth);
