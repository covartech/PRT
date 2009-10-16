function DataSet = prtDataSwissRoll

swissRollFile = fullfile(prtRoot,'data','swissRoll','swiss_roll_data.mat');
swiss = load(swissRollFile);
X = swiss.X_data';
Y = swiss.Y_data';

DataSet = prtDataSet(X,Y,'dataSetName','Standard Swiss Roll Data');