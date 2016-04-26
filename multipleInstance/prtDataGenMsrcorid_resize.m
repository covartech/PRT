function ds = prtDataGenMsrcorid
% ds = prtDataGenMsrcorid
%  Requires some images we can't distribute, so we need to standardize
%  where to get and where to put.
% 
%  (For now, clever googling should find them)







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
