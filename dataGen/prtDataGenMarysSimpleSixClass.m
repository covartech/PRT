function dataSet = prtDataGenMarysSimpleSixClass(nSamples)
% DataSet = prtDataGenMarysSimpleSixClass(nSamples)








if nargin < 1
    nSamples = 100;
end
dsMary1 = prtDataGenMarySimple(nSamples);
dsMary2 = prtDataGenMarySimple(nSamples);
dsMary2.X = bsxfun(@plus,dsMary2.getX,[-3 -3]);
dsMary2.Y = dsMary2.getY + max(dsMary2.getY);
dataSet = catObservations(dsMary1,dsMary2);
