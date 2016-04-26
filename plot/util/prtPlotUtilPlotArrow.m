function varargout = prtPlotUtilPlotArrow(x, y, h, varargin)
% Internal function, 
% xxx Need Help xxx
% PRPLOTUTILPLOTARROW - Plots an arrow








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
