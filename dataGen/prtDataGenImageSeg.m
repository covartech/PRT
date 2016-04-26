function DataSet = prtDataGenImageSeg
%[X,Y] = prtDataGenImageSeg;





file = 'image-seg.data';

[c,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,...
    f11,f12,f13,f14,f15,f16,f17,f18] = textread(file,['%s',repmat('%f',1,18)]);

Y = str2uStrNum(c);
X = cat(2,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,f18);

DataSet = prtDataSetClass(X,Y,'name',mfilename);

function x = str2uStrNum(str,blank)

if nargin == 1
    blank = '';
end

x = nan(size(str,1),1);
u = unique(str);
for i = 1:length(u);
    x(strcmpi(str,u{i})) = i;
end
x(strcmpi(str,blank)) = nan;
