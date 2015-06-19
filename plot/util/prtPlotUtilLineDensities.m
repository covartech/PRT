function h = prtPlotUtilLineDensities(xInd,cY,linecolor,linewidth,faceAlpha,qval)
% Internal function, 
% xxx Need Help xxx

% Copyright (c) 2014 CoVar Applied Technologies
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.



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
