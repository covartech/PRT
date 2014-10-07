function ds = prtDataGenMultipleInstance(nBagsPerHypothesis, nObservationsPerBag, nH1InstancesPerBag)
%ds = prtDataGenMultipleInstance
% 

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
