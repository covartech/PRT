function [ds,dsTest] = prtDataGenTextGender
%   prtDataGenTextGender Read in data from the Kaggle Text/Gender ICDAR 2013 data set
%
%   ds = prtDataGenTextGender generates a prtDataSetClass containing data
%     from the Kaggle  ICDAR 2013 Text/Gender database.  To obtain the
%     database, please download the CSV files from
%       http://www.kaggle.com/c/icdar2013-gender-prediction-from-handwriting/data
%     And extract it to: 
%       fullfile(prtRoot,'dataGen','dataStorage','kaggleTextGender_2013');
% 
%   So that:
%       fullfile(prtRoot,'dataGen','dataStorage','kaggleTextGender_2013','train.csv')
%   points to a valid file.
%
%   Note that it is not necessary to download the image .ZIP files for this
%   to work; all that is required is "train.csv", "train_answers.csv", and
%   "test.csv".
%
%   % Example:
%   ds = prtDataGenTextGender;
%   pca = prtPreProcPca;
%   pca = pca.train(ds);
%   dsPca = pca.run(ds);
%   plot(dsPca);



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

prtPath('beta')
baseDir = fullfile(prtRoot,'dataGen','dataStorage','kaggleTextGender_2013');
if ~exist(baseDir,'dir')
    error('prt:MissingData','Could not locate the Kaggle Text/Gender CSV files in the folder %s; please download the database and extract it from here: http://www.kaggle.com/c/icdar2013-gender-prediction-from-handwriting/data',baseDir);
end

trainFile = fullfile(baseDir,'train.csv');
if ~exist(trainFile,'file');
   error('prt:MissingData','Could not locate the Kaggle Text/Gender CSV file train.csv in the folder %s; please download the database and extract it from here: http://www.kaggle.com/c/icdar2013-gender-prediction-from-handwriting/data',baseDir);
end
trainAnswersFile = fullfile(baseDir,'train_answers.csv');
if ~exist(trainAnswersFile,'file');
   error('prt:MissingData','Could not locate the Kaggle Text/Gender CSV file train_answers.csv in the folder %s; please download the database and extract it from here: http://www.kaggle.com/c/icdar2013-gender-prediction-from-handwriting/data',baseDir);
end
testFile = fullfile(baseDir,'test.csv');
if ~exist(testFile,'file');
   error('prt:MissingData','Could not locate the Kaggle Text/Gender CSV file test.csv in the folder %s; please download the database and extract it from here: http://www.kaggle.com/c/icdar2013-gender-prediction-from-handwriting/data',baseDir);
end

[x,t,c] = xlsread(trainFile);

X = x(:,5:end);
featureNames = t(5:end);
writerId = x(:,1);
pageId = x(:,2);
language = c(2:end,3);
sameText = x(:,4);

[x,t,c] = xlsread(trainAnswersFile);

gender = nan(length(writerId),1);
for i = 1:length(x)
    gender(writerId == x(i,1)) = x(i,2);
end

ds = prtDataSetClass(X,gender);
ds = ds.setObservationInfo('writerId',writerId);
ds = ds.setObservationInfo('language',language);
ds = ds.setObservationInfo('sameText',sameText);
ds.classNames = {'Female','Male'};

% Test:
[x,t,c] = xlsread(testFile);

X = x(:,5:end);
featureNames = t(5:end);
writerId = x(:,1);
pageId = x(:,2);
language = c(2:end,3);
sameText = x(:,4);

dsTest = prtDataSetClass(X);
dsTest = dsTest.setObservationInfo('writerId',writerId);
dsTest = dsTest.setObservationInfo('language',language);
dsTest = dsTest.setObservationInfo('sameText',sameText);