function [dsCasi,dsLidar] = prtExampleReadGrss2013(baseDir)
% [dsCasi,dsLidar] = prtExampleReadGrss2013(baseDir)
%    Read in the data from the 2013 IEEE GRSS Fusion Contest.  
%
%    baseDir should be a string containing the directory where relevant
%    GRSS .TIF and .TXT files reside, e.g., 
%
%    fullfile(baseDir,'2013_IEEE_GRSS_DF_Contest_LIDAR.tif')
%
%    should reference the actual TIF file.  The data can be obtained here:
%     http://hyperspectral.ee.uh.edu/?page_id=459
%  

if nargin == 0
    baseDir = pwd;
end

lidarFile = fullfile(baseDir,'2013_IEEE_GRSS_DF_Contest_LIDAR.tif');
casiFile = fullfile(baseDir,'2013_IEEE_GRSS_DF_Contest_CASI.tif');
roiFile = fullfile(baseDir,'2013_IEEE_GRSS_DF_Contest_Samples_TR.txt');
keyboard
if ~exist(lidarFile,'file')
    error('prtExampleReadGrss2013:missingLidarFile','The LIDAR file 2013_IEEE_GRSS_DF_Contest_LIDAR.tif was not found in %s',baseDir);
end
if ~exist(casiFile,'file')
    error('prtExampleReadGrss2013:missingCasiFile','The CASI file 2013_IEEE_GRSS_DF_Contest_CASI.tif was not found in %s',baseDir);
end
if ~exist(roiFile,'file')
    error('prtExampleReadGrss2013:missingTxtFile','The ROI file 2013_IEEE_GRSS_DF_Contest_Samples_TR.txt was not found in %s',baseDir);
end

xLidar = imread(lidarFile);
xCasi = imread(casiFile);
regions = grssRoiRead(roiFile);

xCasi = permute(xCasi,[3 1 2]);

labels = nan(size(xCasi,2),size(xCasi,3));
for i = 1:length(regions);
    ind = sub2ind([size(xCasi,2),size(xCasi,3)],regions(i).xy(:,2),regions(i).xy(:,1));
    labels(ind) = i;
end

dsCasi = prtDataSetClass(double(xCasi(:,:)'));
dsCasi.targets = labels(:);
dsCasi.classNames = {regions.name};
dsLidar = prtDataSetClass(double(xLidar(:)));
dsLidar.targets = labels(:);
dsLidar.classNames = {regions.name};