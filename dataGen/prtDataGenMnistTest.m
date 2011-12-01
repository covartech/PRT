function ds = prtDataGenMnistTest(nImages)
%ds = prtDataGenMnistTest
%ds = prtDataGenMnistTest(nImages = 10000)

maxImages = 10000; %its a fact
if nargin < 1
    nImages = 10000;
end
offset = 0;

dataDir = fullfile(prtRoot,'dataGen','dataStorage','MNIST');
imgFile = fullfile(dataDir,'t10k-images.idx3-ubyte');
labelFile = fullfile(dataDir,'t10k-labels.idx1-ubyte');

if ~exist(imgFile,'file') || ~exist(labelFile,'file')
    error('The MNIST database files were not found in the folder \r\t %s.  Please download the MNIST database from http://yann.lecun.com/exdb/mnist/ and extract the -ubyte files into %s',dataDir,dataDir);
end

if nImages > maxImages
    error(sprintf('MNIST test database only contains %d images',maxImages)); %#ok<SPERR>
end

[imgs y] = prtUtilReadMNIST(imgFile, labelFile, nImages, offset);

x = reshape(imgs,[size(imgs,1)*size(imgs,2),size(imgs,3)])';
ds = prtDataSetClass(x,y);