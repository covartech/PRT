function ds = prtDataGenMultipleInstanceMultinomial(varargin)

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
