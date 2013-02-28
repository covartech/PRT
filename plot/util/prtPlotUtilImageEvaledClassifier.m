function imageHandle = prtPlotUtilImageEvaledClassifier(DS,linGrid,gridSize,cMap)
% Internal function, 
% xxx Need Help xxx

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


nDims = size(linGrid,2);

switch nDims
    case 1
        imageHandle = imagesc(linGrid(:,1),linGrid(:,2),DS);
        set(gca,'YTickLabel',[])
        colormap(cMap)
    case 2
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        imageHandle = imagesc(xx(1,:),yy(:,1),DS);
        colormap(cMap)
    case 3
        xx = reshape(linGrid(:,1),gridSize);
        yy = reshape(linGrid(:,2),gridSize);
        zz = reshape(linGrid(:,3),gridSize);
        imageHandle = slice(xx,yy,zz,DS,max(xx(:)),max(yy(:)),[min(zz(:)),mean(zz(:))]);
        view(3)
        colormap(cMap)
end
axis tight;
axis xy;

