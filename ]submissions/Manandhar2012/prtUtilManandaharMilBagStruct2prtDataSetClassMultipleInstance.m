function ds = prtUtilManandaharMilBagStruct2prtDataSetClassMultipleInstance(fileName,nComponents)

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


load(fileName);

nBags = max(bags.bagNum(:));
obsStruct = repmat(struct('data',[]),nBags,1);
y = zeros(nBags,1);

if nargin > 1
    ds = prtDataSetClass(bags.data);
    ds = rt(prtPreProcZmuv +prtPreProcPca('nComponents',nComponents),ds);
    bags.data = ds.X;
end

for iBag = 1:nBags
    obsStruct(iBag).data = bags.data(bags.bagNum==iBag,:);
    y(iBag) = mode(bags.label(bags.bagNum==iBag));
end

ds = prtDataSetClassMultipleInstance(obsStruct,y);

