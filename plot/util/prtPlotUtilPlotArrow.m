function varargout = prtPlotUtilPlotArrow(x, y, h, varargin)
% Internal function, 
% xxx Need Help xxx
% PRPLOTUTILPLOTARROW - Plots an arrow

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



p1 = cat(2,x(1),y(1));
p2 = cat(2,x(2),y(2));

pobj = inputParser;
pobj.addParamValue('realHeadLength',.03);
pobj.addParamValue('lineWidth',.0025);
pobj.addParamValue('headWidth',.01);

pobj.parse(varargin{:});
inpStruct = pobj.Results;
realHeadLength = inpStruct.realHeadLength;
lineWidth = inpStruct.lineWidth;
headWidth = inpStruct.headWidth;

d = sqrt(sum((p1-p2).^2,2));

headPercent = realHeadLength/d;
headLength = headPercent*d;
lineLength = (1-headPercent)*d;

x = [0 lineLength lineLength lineLength+headLength lineLength lineLength 0];
y = [lineWidth lineWidth lineWidth+headWidth 0 -lineWidth-headWidth -lineWidth -lineWidth];

a = cat(2,x(:),y(:));

theta = atan2(p2(2)-p1(2),p2(1)-p1(1));
r = [cos(theta),sin(theta); -sin(theta),cos(theta)];
a = bsxfun(@plus,a*r,p1);

if nargin < 3 || isempty(h)
    h = patch(a(:,1),a(:,2),'k');
else
    set(h,'XData',a(:,1),'YData',a(:,2));
end


varargout = {};
if nargout
    varargout = {h};
end
