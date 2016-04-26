function [VEC,C,V,E] = prtUtilPca(DATA,P)
%[VEC,C,V,E] = getPcaVec(DATA,P);
% xxx Need Help xxx
%







%Peter Torrione
C = cov(DATA);
[V,E] = eig(C);

%sort
[E,IND] = sort(abs(diag(E)));
%re-sorta
E = flipud(E(:));
IND = flipud(IND(:));
V = V(:,IND);

if P < 1    
    NRG = cumsum(E)./sum(E);
    NRGind = find(NRG > P,1,'first');
    VEC = V(:,1:NRGind);
else
    VEC = V(:,1:P);
end

PLOTTING = 0;
if PLOTTING
    plot(DATA'./max(abs(DATA(:))));
    hold on; 
    h = plot(VEC./max(abs(VEC(:))));
    set(h,'linewidth',3);
    pause
    close all;
end
