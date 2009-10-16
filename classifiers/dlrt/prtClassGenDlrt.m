function PrtDlrt = prtClassGenDlrt(PrtDataSet,Options)

if ~PrtDataSet.isBinary
    error('DLRT only accepts binary data sets');
end

PrtDlrt.PrtDataSet = PrtDataSet;
% Place Options structure into the classifier structure
PrtDlrt.PrtOptions = Options;
