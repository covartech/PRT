function h = prtPlotUtilLineDensities(xInd,cY,linecolor,linewidth,faceAlpha,qval)
% Internal function, 
% xxx Need Help xxx





if qval > 0.5;
    qval = 1-qval;
end

if isempty(xInd) || isempty(cY)
    h = nan;
    return
end

q1 = quantile(cY,qval);
q2 = quantile(cY,1-qval);

qpolyx = [xInd(1), xInd, fliplr(xInd)];
qpolyy = [q1(1), q1, fliplr(q2)];

h = plot(xInd,median(cY),'color',linecolor,'linewidth',linewidth);
patch(qpolyx,qpolyy,linecolor,'faceAlpha',faceAlpha,'EdgeColor',linecolor,'lineStyle','--');
