function [dsTrain,dsTest] = prtDataGenCifar10(cifarDir)
% prtDataGenCifar10 - Load the data from the CIFAR-10 database into a
%       prtDataSetCell 
%
% [dsTrain,dsTest] = prtDataGenCifar10(cifarDir) loads the .MAT files
% "data_batch_X.ma" from the directory cifarDir.  You can obtain the CIFAR
% .MAT files from http://www.cs.toronto.edu/~kriz/cifar.html.  
%
%  For example, the result of fullfile(cifarDir,'batches.meta.mat') should
%  point to a valid file.  By default, cifarDir will evaluate to
%  fullfile(prtRoot,'dataGen','dataStorage','cifar-10-batches-mat')
%
%  Note that the resulting data set is not a prtDataSetClass, but a
%  prtDataSetCellArray, where each element of the cell array is a 32x32x3
%  matrix of uint8s.
%
%  Additional processing is required to use this data as part of a PRT
%  processing flow - for example, by extracting features from each cell to
%  create a prtDataSetClass.
%
%  [dsTrain,dsTest] = prtDataGenCifar10;
%  for i = 1:9; 
%       img = dsTrain.X{i};
%       class = dsTrain.classNames{dsTrain.Y(i)+1};
%       subplot(3,3,i);
%       imshow(img); 
%       title(class);
%  end
%

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


prtPath('beta');
if nargin < 1
    cifarDir = fullfile(prtRoot,'dataGen','dataStorage','cifar-10-batches-mat');
end

nameFile = fullfile(cifarDir,'batches.meta.mat');
if ~exist(nameFile,'file')
    error('prtDataGenCifar10:Missing','The file batches.meta.mat was not found in %s; Perhaps you have not downloaded and un-zipped the correct files from http://www.cs.toronto.edu/~kriz/cifar.html ?',cifarDir);
end
nameStruct = load(nameFile,'label_names');

batchVec = [];
for batchInd = 1:5;
    batchFile = sprintf('data_batch_%d.mat',batchInd);
    batchFile = fullfile(cifarDir,batchFile);
    
    dsTemp = batchFileToDataSet(batchFile);
    batchVec = cat(1,batchVec,ones(dsTemp.nObservations,1)*batchInd);
    
    if batchInd == 1
        dsTrain = dsTemp;
    else
        dsTrain = catObservations(dsTrain,dsTemp);
    end
end

dsTrain = dsTrain.setObservationInfo('batchIndex',batchVec);
dsTrain.classNames = nameStruct.label_names;

testFile = fullfile(cifarDir,'test_batch.mat');
dsTest = batchFileToDataSet(testFile);
dsTest = dsTest.setObservationInfo('batchIndex',nan(dsTest.nObservations,1));
dsTest.classNames = nameStruct.label_names;

function ds = batchFileToDataSet(batchFile)

loadStruct = load(batchFile);
for dataInd = 1:size(loadStruct.data,1) %10000
    locCell{dataInd,1} = reshape(loadStruct.data(dataInd,:),[32 32 3]);
    locCell{dataInd,1} = permute(locCell{dataInd,1},[2 1 3]);
end
ds = prtDataSetCellArray(locCell,double(loadStruct.labels));
