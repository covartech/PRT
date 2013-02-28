function result = prtTestFeatSelStatic

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


%%
result = true;
%%



%%
% Check basic operation
try
dataSet = prtDataGenCircles;
featSel = prtFeatSelStatic; 
featSel.selectedFeatures = 1;
featSel = featSel.train(dataSet);
outDataSet = featSel.run(dataSet);
catch
    disp('Error #1, basic feature selection fail')
    result = false;
end

if outDataSet.nFeatures ~=1
    disp('Error #2, wrong # of features')
    result = false;
end

if featSel.isTrained ~= 1
    disp('Error #2a, should be trained')
    result = false;
end

if ~isequal(outDataSet.getX, dataSet.getFeatures(1));
    disp('Error # 3, wrong feature selected')
end

% Cannot set selectedFeatures manually. If you want to do that you want
% prtFeatSelStatic.
% try
%     featSel = prtFeatSelExhaustive('selectedFeatures',2);
% catch
%     disp('Error #4, param/val constructor fail')
%     result = false;
% end

%% Stuff that should error
error = true;
% This errors out messily if you don't train first, should error out clean.
dataSet = prtDataGenSpiral;
featSel = prtFeatSelStatic; 

try
    R = featSel.run(dataSet);
    disp('Error# 5 , run without setting features')
    error = false;
end

result = result & error;


