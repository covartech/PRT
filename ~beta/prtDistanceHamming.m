function D = prtDistanceHamming(x,y)

[x,y] = prtUtilDistanceParseInputs(x,y);

x = logical(x);
y = logical(y);

D = sum(bsxfun(@xor,reshape(x,[size(x,1),1,size(x,2)]),reshape(y,[1,size(y,1),size(y,2)])),3);