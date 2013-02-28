function prtUtilPlotConfusionMatrixSimple(guesses,truth)
% prtUtilPlotConfusionMatrixSimple(guesses,truth)
% 
% guesses = {'a';'b';'c'};
% truth = {'1';'2';'3'};
% prtUtilPlotConfusionMatrixSimple(guesses,truth)
%
% 
% guesses = {'a';'b';'c'};
% truth = {'a';'c';'b'};
% prtUtilPlotConfusionMatrixSimple(guesses,truth)

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


if isnumeric(guesses)
    error('prtUtilPlotConfusionMatrixSimple requires string cell-array guesses and truth');
end

uniqueGuesses = unique(guesses);
uniqueTruth = unique(truth);

confusionMat = zeros(length(uniqueTruth),length(uniqueGuesses));
for i = 1:length(uniqueTruth)
    inTruth = strcmpi(uniqueTruth{i},truth);
    for j = 1:length(uniqueGuesses)
        inTruthGuesses = strcmpi(uniqueGuesses{j},guesses(inTruth));
        confusionMat(i,j) = sum(inTruthGuesses);
    end
end

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

[imageAxes] = prtUtilPlotMatrixTable(percentageConfusionMat*100,[0 100],flipud(gray(256)),'%0.1f',[0 0 0; 1 1 1;]);

axes(imageAxes);
set(imageAxes,'Ytick',1:size(confusionMat,1));
set(imageAxes,'Xtick',1:size(confusionMat,2));
xlabel('Response'); ylabel('Truth');
set(imageAxes,'Yticklabel',uniqueTruth);
set(imageAxes,'Xticklabel',uniqueGuesses);

sideTextHandles = zeros(size(confusionMat,1),1);

if exist('occurances','var');
    for j = 1:size(confusionMat,1)
        sideTextHandles(j) = text(size(confusionMat,2)+1-0.375,j,...
            sprintf('[%d]',occurances(j)),...
            'color',[0 0 0],...
            'horizontalAlignment','left',...
            'verticalAlignment','middle',...
            'fontsize',get(gca,'fontsize'),...
            'clipping','off','visible','on');
    end
end
