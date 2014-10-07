function DataSet = prtDataGenImageSeg
%[X,Y] = prtDataGenImageSeg;

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
