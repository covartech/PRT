function ds = prtTestBigData

tempMatFileName = 'prtTestBigDataMat.mat';
dsOrig = prtDataGenMary;
data = dsOrig.getX;
save(tempMatFileName,'data');

%Test plotting:
ds = prtDataSetClassBigData;
ds.matFileName = tempMatFileName;
ds.Y = dsOrig.getY;
plot(ds);

% this should error
try
    ds.X = ds.X;
catch ME
    disp('error caught.  that''s good');
end

%Should be OK
ds.writeMode = 'newFile';
ds.X = ds.X;

plot(ds);

%
c = prtClassPlsda + prtDecisionMap;
yOut = c.kfolds(ds,10);
prtScoreConfusionMatrix(yOut);
