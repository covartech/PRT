

dataSet = prtDataGenNoisySinc;

reg = prtRegressRvm('learningVerbose',true,'learningPlot',true);
reg = reg.train(dataSet);

reg.plot();
legend('Regression curve','Original Points','Relevence Vectors')
%%

dataSet = prtDataGenNoisySinc;

reg = prtRegressRvmSequential('learningVerbose',true,'learningPlot',true);
reg = reg.train(dataSet);

reg.plot();
legend('Regression curve','Original Points','Relevence Vectors')

%%
TrainingData = prtDataGenNoisySinc;

regSet{1} = prtRegressRvm('learningVerbose',true);
regSet{1} = regSet{1}.train(TrainingData);

regSet{2} = prtRegressRvmSequential('learningVerbose',true);
regSet{2} = regSet{2}.train(TrainingData);

subplot(2,1,1)
regSet{1}.plot();
subplot(2,1,2)
regSet{2}.plot();
