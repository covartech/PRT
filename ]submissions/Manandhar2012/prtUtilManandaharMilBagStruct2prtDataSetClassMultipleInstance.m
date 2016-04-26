function ds = prtUtilManandaharMilBagStruct2prtDataSetClassMultipleInstance(fileName,nComponents)







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

