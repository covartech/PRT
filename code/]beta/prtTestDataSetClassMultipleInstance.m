%%

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
clear classes

h0rv = prtRvGmm('nComponents',3,'components',cat(1,prtRvMvn('mu',[2 2],'sigma',eye(2)),prtRvMvn('mu',[0 0],'sigma',eye(2)),prtRvMvn('mu',[2 0],'sigma',eye(2))));
h1rv = prtRvGmm('nComponents',3,'components',cat(1,prtRvMvn('mu',[-2 -2],'sigma',eye(2)),prtRvMvn('mu',[-4 0],'sigma',eye(2)),prtRvMvn('mu',[0 6],'sigma',eye(2))));

nBagsH0 = 100;
nBagsH1 = 100;
nObsPerBag = 10;
nObsPerBagH1 = 5;
xh0 = h0rv.draw(nBagsH0*nObsPerBag + nBagsH1*(nObsPerBag-nObsPerBagH1));
xh1 = h1rv.draw(nBagsH1*nObsPerBagH1);

x = zeros((nBagsH0 + nBagsH1)*nObsPerBag, 2);

x(1:(nBagsH0*nObsPerBag),:) = xh0(1:(nBagsH0*nObsPerBag),:);
h1Inds = (reshape(kron((1:nObsPerBagH1)',ones(1,nBagsH1)),[],1) + kron((0:(nBagsH1-1))'*nObsPerBag,ones(nObsPerBagH1,1)));
x((nBagsH0*nObsPerBag) + h1Inds,:) = xh1;
x((nBagsH0*nObsPerBag) + setdiff(1:(nObsPerBag*nBagsH1),h1Inds),:) = xh0((nBagsH0*nObsPerBag + 1):end,:);

bags = kron((1:(nBagsH0+nBagsH1))',ones(nObsPerBag,1));
bagTargets = prtUtilY(nBagsH0,nBagsH1);
y = kron(bagTargets,ones(nObsPerBag,1));

bagInfo = repmat(struct('bagInd',[],'bagName',[],'bagTarget',[],'nObs',[]),length(bagTargets),1);
for iBag = 1:length(bagTargets)
    bagInfo(iBag,1).bagInd = iBag;
    bagInfo(iBag,1).bagName = sprintf('Bag %03d',iBag);
    bagInfo(iBag,1).bagTarget = bagTargets(iBag);
    bagInfo(iBag,1).nObs = sum(bags==iBag);
end

nBags = nBagsH0 + nBagsH1;

% nBags - length(unique(bags)) - uniqueBags should be cached
% bagTargets - Length of nBags, holds the bag labels
% nObservationsByBag - histc(bags,unique(bags))
% nBagsByUniqueClass - histc(bagTargets,unique(bagTargets)) -
% uniqueBagTargets should be cached or we can use uniqueTargets (which should be the same and should be cached)

xCell = mat2cell(x,nObsPerBag*ones(nBagsH0 + nBagsH1,1),2);

ds = prtDataSetClassMultipleInstance(xCell, bagTargets);
