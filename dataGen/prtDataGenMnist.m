function ds = prtDataGenMnist(nImages)
%  prtDataGenMnist Generate a prtDataSetClass containing the MNIST training
%   data
% 
% ds = prtDataGenMnist; Generates a prtDataSetClass, ds, containing the
%   first 10000 images from the MNIST data.  The images are 28x28 pixels, and
%   are stored as 1x784 feature vectors, so ds.getX(1) returns a 1x784
%   element vector.  Class targets (ds.getY(i)) correspond to the correct
%   written digit.
% 
% ds = prtDataGenMnist(nImages) returns nImages total images from the MNIST
%  training set.  nImages must be less than or equal to 60000.







maxImages = 60000; %its a fact
if nargin < 1
    nImages = 10000;
end
offset = 0;

dataDir = fullfile(prtRoot,'dataGen','dataStorage','MNIST');
imgFile = fullfile(dataDir,'train-images.idx3-ubyte');
labelFile = fullfile(dataDir,'train-labels.idx1-ubyte');

if ~exist(imgFile,'file') || ~exist(labelFile,'file')
    error('The MNIST database files were not found in the folder \r\t %s.  Please download the MNIST database from http://yann.lecun.com/exdb/mnist/ and extract the -ubyte files into %s',dataDir,dataDir);
end

if nImages > maxImages
    error(sprintf('MNIST training database only contains %d images',maxImages)); %#ok<SPERR>
end

[imgs y] = prtUtilReadMNIST(imgFile, labelFile, nImages, offset);

x = reshape(imgs,[size(imgs,1)*size(imgs,2),size(imgs,3)])';
ds = prtDataSetClass(x,y);
ds.classNames = {'0','1','2','3','4','5','6','7','8','9','10'};
