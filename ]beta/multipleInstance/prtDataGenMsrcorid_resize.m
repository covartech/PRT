function ds = prtDataGenMsrcorid
% ds = prtDataGenMsrcorid
%  Requires some images we can't distribute, so we need to standardize
%  where to get and where to put.
% 
%  (For now, clever googling should find them)

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


baseDir = 'C:\Users\pete\Documents\data\images\msrcorid';
completeFiles = prtUtilSubDir(baseDir,'*.jpg');

imResizeSize = [100,100];

imgMat = nan(length(completeFiles),prod(imResizeSize));
for i = 1:length(completeFiles);
    files{i} = strrep(lower(completeFiles{i}),lower(baseDir),'');
    
    p = fileparts(files{i});
    
    class{i} = sprintf('%s ',p{1:end-1});
    class{i} = strtrim(class{i});
    
    img = prtDataTypeImage(completeFiles{i});
    
    imgSize = img.getImageSize;
    if imgSize(1) == 480;
        img = imcrop(img,[320-240+1,0,479,480]);
    else
        img = imcrop(img,[0,320-240+1,480,479]);
    end
    g = img.gray;
    g = imresize(g,imResizeSize);
    imgMat(i,:) = g(:);
end

[y,uClasses] = prtUtilStringsToClassNumbers(class);
ds = prtDataSetClass(imgMat,y);
ds.classNames = uClasses;
