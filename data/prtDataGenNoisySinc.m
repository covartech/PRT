function DataSet = prtDataGenNoisySinc
% DataSet = prtDataGenNoisySync
% 
% 

nSamples = 100;
noiseVar = 0.1;

t = linspace(-10,10,1000);
x = randsample(t,nSamples)';
t = sinc(x/pi);
y = t + noiseVar*randn(size(x));

DataSet = prtDataSetRegress(x,y,'name','Noisy Sinc');