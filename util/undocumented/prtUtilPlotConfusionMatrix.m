function varargout = prtUtilPlotConfusionMatrix(confusionMat,classLabels,classLabels2)
% prtUtilPlotConfusionMatrix  Generate a colorful plot to view a confusion matrix.
%   The confusion matrix lists truth along the rows and the responses along
%   the columns. If the confusion matrix lists number of responses and not
%   percentage of response, the number of responses are listed to the right
%   of the last column.
%
% Syntax:  plotConfusionMatrix(confusionMat,classLabels,textColor)
%
% Inputs:
%   confusionMat - A confusion matrix, more than likely created using
%       confustionmatrix.m or a similar function.
%   classLabels - The labels of each of the classes. If this is ommitted or
%       an empty matrix the classes are labeled as integers starting at 1.
%
% Outputs:
%   h - The handle to created figure.
%
% Example: 
%   truth = [1 1 1 1 1 2 2 2 3 3 3 3 4 4 4 4 4 4];
%   resp  = [1 1 1 1 1 3 2 2 3 3 4 2 4 3 4 4 3 2];
%   [confusionMat, occurances] = confusionMatrix(truth,resp);
%   plotConfusionMatrix(confusionMat)
%   % Another example
%   truth = [1 1 1 1 1 2 2 2 3 3 3 3 4 4 4 4 4 4 5 5 5 5 5 6 6 6 6 6 7 7 7 7 7 8 8 8 8 8 9 9 9 9 9 10 10 10 10 10];
%   resp  = [1 1 1 1 1 3 2 2 3 3 4 2 4 3 4 4 3 2 5 5 4 3 2 6 6 6 6 6 7 7 2 2 1 8 8 8 7 7 9 9 9 9 1 10 10 7  6  5];
%   [confusionMat, occurances] = confusionMatrix(truth,resp);
%   plotConfusionMatrix(confusionMat)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: confusionMatrix.m confusion2PercentCorrect.m

% Copyright (c) 2013 New Folder Consulting
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



nClass = size(confusionMat,1);

% Make a percentage matrix if it is not already. Also, if it is not count
% the number of occurances.
if ~all(prtUtilApproxEqual(sum(confusionMat,2),1))
    occurances = sum(confusionMat,2);
    percentageConfusionMat = bsxfun(@rdivide,confusionMat,occurances);
else
    percentageConfusionMat = confusionMat;
end

if exist('occurances','var')
    cla reset;
end
percentageConfusionMat(isnan(percentageConfusionMat)) = 0;

[imageAxes, textHandles, verticleLineHandles, horizontalLineHandles] = prtUtilPlotMatrixTable(percentageConfusionMat*100,[0 100],flipud(gray(256)),'%0.1f',[0 0 0; 1 1 1;]);

if ~exist('classLabels','var') || isempty(classLabels)
    numericalLabels = true;
else
    if isempty(classLabels)        
        numericalLabels = true;
    else
        numericalLabels = false;
    end
end    
    
if numericalLabels
    for iClass = 1:nClass
        classLabels{iClass} = num2str(iClass);
    end
end

if nargin < 3 || isempty(classLabels2)
    classLabels2 = classLabels;
end

axes(imageAxes);
set(imageAxes,'Ytick',1:size(confusionMat,1));
set(imageAxes,'Xtick',1:size(confusionMat,2));
xlabel('Response'); ylabel('Truth');
set(imageAxes,'Yticklabel',classLabels2);
set(imageAxes,'Xticklabel',classLabels);


sideTextHandles = zeros(nClass,1);

if exist('occurances','var');
    for j = 1:nClass
        sideTextHandles(j) = text(size(confusionMat,2)+1-0.375,j,...
            sprintf('[%d]',occurances(j)),...
            'color',[0 0 0],...
            'horizontalAlignment','left',...
            'verticalAlignment','middle',...
            'fontsize',get(gca,'fontsize'),...
            'clipping','off','visible','on');
    end
end

if nargout > 0 
    varargout = {imageAxes, textHandles, sideTextHandles};
end
