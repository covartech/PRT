function DataSet = prtDataGenSinc(N)

if nargin == 0
	N = 30;
end

x = rand(N,1)*2*pi - pi;
y = sinc(x) + randn(size(x))/10;

DataSet = prtDataSetRegress(x,y,'name','prtDataGenSinc');