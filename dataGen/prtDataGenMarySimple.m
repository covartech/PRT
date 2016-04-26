function DataSet = prtDataGenMarySimple(nSamples)
% prtDataGenMary  Generate unimodal M-ary example data
%









if nargin < 1
    nSamples = 100;
end
rvH1 = prtRvMvn('mu',[0 0],'sigma',1*eye(2));
rvH2 = prtRvMvn('mu',[2 2],'sigma',1*eye(2));
rvH3 = prtRvMvn('mu',[4 0],'sigma',eye(2));
X = cat(1,draw(rvH1,nSamples),draw(rvH2,nSamples),draw(rvH3,nSamples));
Y = prtUtilY(0,nSamples,nSamples,nSamples);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenMary');
