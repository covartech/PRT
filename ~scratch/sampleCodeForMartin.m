%% Load some data:
clear all;
close all;

load xy.mat x y
sigma = 1;

% Make a grid for imaging later
[xx,yy] = meshgrid(linspace(-5,5,40));

%% Train the RVM:
r = sequentialRvmTrainAction(x,y,sigma);

%% Run the RVM to make a pretty picture
yOutImage = sequentialRvmRunAction(r,[xx(:),yy(:)]);
yOutImage = reshape(yOutImage,size(xx));

imagesc(xx(1,:),yy(:,1),yOutImage);
hold on; plot(x(y == 1,1),x(y == 1,2),'r.',x(y == 0,1),x(y == 0,2),'b.'); hold off;
axis xy;

%% Run the RVM and score on simple data
yOut = sequentialRvmRunAction(r,x);
prtScoreRoc(yOut,y);