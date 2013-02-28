function [VEC,C,V,E] = prtUtilPca(DATA,P)
%[VEC,C,V,E] = getPcaVec(DATA,P);
% xxx Need Help xxx
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
