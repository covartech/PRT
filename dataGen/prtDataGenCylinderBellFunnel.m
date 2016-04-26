function ds = prtDataGenCylinderBellFunnel
% prtDataGenCylinderBellFunnel Generate Cylinder, Bell, Funnel Data
% 
% ds = prtDataGenCylinderBellFunnel returns a prtDataSetClass with data
%  from 3 classes: cylinder, bell, and funnel shapes.  These are
%  time-series with 128 samples, each with a section of somewhat random
%  length either flat (cylinder), rising (bell), or falling (funnel).
%
%  See: http://www.cse.unsw.edu.au/~waleed/phd/html/node119.html for
%  specifications, and "Clustering of Time Series Subsequences is
%  Meaningless" for example usage.   
%






nSamples = 266;

[c,b,f] = genCylBellFun(nSamples);
x = cat(1,c,b,f);
y = prtUtilY(nSamples,nSamples,nSamples);
ds = prtDataSetClass(x,y);
ds.classNames = {'Cylinder','Bell','Funnel'};


function [cylinder,bell,funnel] = genCylBellFun(nSamples)
% See: http://www.cse.unsw.edu.au/~waleed/phd/html/node119.html

t = 1:128;
t = repmat(t,nSamples,1);

% Cylinder
a = round(rand(nSamples,1)*16+16);
a = repmat(a,1,128);
bMinusA = round(rand(nSamples,1)*64+32);
bMinusA = repmat(bMinusA,1,128);
b = bMinusA + a;

eta = randn(nSamples,1);
eta = repmat(eta(:),1,128);
noise = randn(nSamples,128);

cylinder = (6 + eta).*double(t >= a & t <= b) + noise;

% Bell
a = round(rand(nSamples,1)*16+16);
a = repmat(a,1,128);
bMinusA = round(rand(nSamples,1)*64+32);
bMinusA = repmat(bMinusA,1,128);
b = bMinusA + a;

eta = randn(nSamples,1);
eta = repmat(eta(:),1,128);
noise = randn(nSamples,128);

bell = (6 + eta).*double(t >= a & t <= b).*(t-a)./(b-a) + noise;

% Funnel
a = round(rand(nSamples,1)*16+16);
a = repmat(a,1,128);
bMinusA = round(rand(nSamples,1)*64+32);
bMinusA = repmat(bMinusA,1,128);
b = bMinusA + a;

eta = randn(nSamples,1);
eta = repmat(eta(:),1,128);
noise = randn(nSamples,128);

funnel = (6 + eta).*double(t >= a & t <= b).*(b-t)./(b-a) + noise;

