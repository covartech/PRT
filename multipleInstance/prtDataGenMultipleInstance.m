function ds = prtDataGenMultipleInstance(nBagsPerHypothesis, nObservationsPerBag, nH1InstancesPerBag)
%ds = prtDataGenMultipleInstance
% 







if nargin < 1 || isempty(nBagsPerHypothesis)
	nBagsPerHypothesis = 100;
end

if nargin < 2 || isempty(nObservationsPerBag)
	nObservationsPerBag = 10;
end

if nargin < 2 || isempty(nH1InstancesPerBag)
	nH1InstancesPerBag = 1;
end

R{1} = prtRvGmm('nComponents',2,'mixingProportions',[0.5; 0.5],'components',cat(1,prtRvMvn('mu',[0 0],'sigma',eye(2)*2),prtRvMvn('mu',[-6 -6],'sigma',eye(2))));
R{2} = prtRvGmm('nComponents',2,'mixingProportions',[0.5; 0.5],'components',cat(1,prtRvMvn('mu',[2 2],'sigma',[1 .5; .5 1]),prtRvMvn('mu',[-3 -3],'sigma',[1 .5; .5 1])));
%R{2} = prtRvGmm('nComponents',2,'mixingProportions',[0.5; 0.5],'components',cat(1,prtRvMvn('mu',[6 6],'sigma',[1 .5; .5 1]),prtRvMvn('mu',[-6 6],'sigma',[1 .5; .5 1])));

X = repmat(struct('data',[]),nBagsPerHypothesis*2,1);
for iBag = 1:size(X,1)
    if iBag <= nBagsPerHypothesis
        cX = draw(R{1}, nObservationsPerBag);
    else
        cXH0 = draw(R{1}, nObservationsPerBag-nH1InstancesPerBag);
        cXH1 = draw(R{2}, nH1InstancesPerBag);
        
        cX = cat(1,cXH0,cXH1);
    end
    X(iBag).data = cX;
end

Y = prtUtilY(nBagsPerHypothesis, nBagsPerHypothesis);

ds = prtDataSetClassMultipleInstance(X,Y,'name','prtDataGenMultipleInstance');
