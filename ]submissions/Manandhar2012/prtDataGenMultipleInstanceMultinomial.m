function ds = prtDataGenMultipleInstanceMultinomial(varargin)







p = inputParser;
p.addParamValue('nBagsPerHypothesis',100);
p.addParamValue('nObservationsPerBag',10);
p.addParamValue('nH1InstancesPerBag',1);
p.addParamValue('nWordsPerParagraph',20);
p.addParamValue('nDimensions',5);

p.parse(varargin{:});
params= p.Results;


R{1} = prtRvMixture('mixingProportions',[0.5; 0.5],'components',cat(1,prtRvMultinomial('probabilities',prtRvUtilDirichletDraw(ones(params.nDimensions)),'nDrawsPerObservationDraw',params.nWordsPerParagraph),prtRvMultinomial('probabilities',prtRvUtilDirichletDraw(ones(params.nDimensions)),'nDrawsPerObservationDraw',params.nWordsPerParagraph)));
R{2} = prtRvMixture('mixingProportions',[0.5; 0.5],'components',cat(1,prtRvMultinomial('probabilities',prtRvUtilDirichletDraw(ones(params.nDimensions)),'nDrawsPerObservationDraw',params.nWordsPerParagraph),prtRvMultinomial('probabilities',prtRvUtilDirichletDraw(ones(params.nDimensions)),'nDrawsPerObservationDraw',params.nWordsPerParagraph)));

X = repmat(struct('data',[]),params.nBagsPerHypothesis*2,1);
for iBag = 1:size(X,1)
    if iBag <= params.nBagsPerHypothesis
        cX = draw(R{1}, params.nObservationsPerBag);
    else
        cXH0 = draw(R{1}, params.nObservationsPerBag-params.nH1InstancesPerBag);
        cXH1 = draw(R{2}, params.nH1InstancesPerBag);
        
        cX = cat(1,cXH0,cXH1);
    end
    X(iBag).data = cX;
end

Y = prtUtilY(params.nBagsPerHypothesis, params.nBagsPerHypothesis);

ds = prtDataSetClassMultipleInstance(X,Y,'name','prtDataGenMultipleInstance');
