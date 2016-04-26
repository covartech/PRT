function D = prtDistanceHamming(x,y)








[x,y] = prtUtilDistanceParseInputs(x,y);

x = logical(x);
y = logical(y);

%%
%tic
%D2 = sum(bsxfun(@xor,reshape(x,[size(x,1),1,size(x,2)]),reshape(y,[1,size(y,1),size(y,2)])),3);
%toc
%%
D = zeros(size(x,1),size(y,1));
%tic
for iY = 1:size(y,1)
    D(:,iY) = sum(bsxfun(@xor,x,y(iY,:)),2);
end
%toc
