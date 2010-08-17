function DataSet = prtDataSwissRoll

swissRollFile = fullfile(prtRoot,'data','swissRoll','swiss_roll_data.mat');
swiss = load(swissRollFile);
X = swiss.X_data';
Y = swiss.Y_data';

DataSet = prtDataSetRegress(X,Y,'name','Standard Swiss Roll Data');