function h = prtPlotUtilDataSetPlotIndividual(ds)

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


origHoldState = ishold;

h = zeros(ds.nObservations,1);
nFeatures = ds.nFeatures;
X = ds.X;
for iObs = 1:ds.nObservations
    switch nFeatures
        case 1
            h(iObs) = plot(X(iObs,1),'.');
        case 2
            h(iObs) = plot(X(iObs,1),X(iObs,2),'.');
        case 3
            h(iObs) = plot3(X(iObs,1),X(iObs,2),X(iObs,3),'.');
        otherwise
             error('prt:prtPlotUtilDataSetPlotIndividual:plotDimensionality','The number of requested plot dimensions (%d) is greater than 3. You may want to use explore() to select and visualize a subset of the features.',nPlotDimensions);
    end
    hold on
end
if ~origHoldState
    hold off
end
