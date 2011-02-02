function result = prtTestFeatSelStatic

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
dataSet = prtDataGenSpiral3Regress;
featSel = prtFeatSelStatic; 

try
    R = featSel.run(dataSet);
    disp('Error# 5 , run without setting features')
    error = false;
end

result = result & error;


