function DataSet = prtDataNoisySync

nSamples = 100;
noiseVar = 0.1;

t = linspace(-10,10,1000);
x = randsample(t,nSamples)';
t = sinc(x/pi);
y = t + noiseVar*randn(size(x));

DataSet = prtDataSetClass(x,y,'name','Noisy Sync');