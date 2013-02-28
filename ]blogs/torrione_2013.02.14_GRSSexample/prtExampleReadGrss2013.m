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
