function [imgs labels] = prtUtilReadMNIST(imgFile, labelFile, readDigits, offset)
% prtUtilReadMNIST is just readMNIST by Siddharth Hegde; available from:
% http://www.mathworks.com/matlabcentral/fileexchange/27675-read-digits-and-labels-from-mnist-database
%
% Description:
% Read digits and labels from raw MNIST data files
% File format as specified on http://yann.lecun.com/exdb/mnist/
% Note: The 4 pixel padding around the digits will be remove
%       Pixel values will be normalised to the [0...1] range
%
% Usage:
% [imgs labels] = readMNIST(imgFile, labelFile, readDigits, offset)
%
% Parameters:
% imgFile = name of the image file
% labelFile = name of the label file
% readDigits = number of digits to be read
% offset = skips the first offset number of digits before reading starts
%
% Returns:
% imgs = 20 x 20 x readDigits sized matrix of digits
% labels = readDigits x 1 matrix containing labels for each digit
%
% Read digits







fid = fopen(imgFile, 'r', 'b');
header = fread(fid, 1, 'int32');
if header ~= 2051
    error('Invalid image file header');
end
count = fread(fid, 1, 'int32');
if count < readDigits+offset
    error('Trying to read too many digits');
end

h = fread(fid, 1, 'int32');
w = fread(fid, 1, 'int32');

if offset > 0
    fseek(fid, w*h*offset, 'cof');
end

imgs = zeros([h w readDigits]);

for i=1:readDigits
    for y=1:h
        imgs(y,:,i) = fread(fid, w, 'uint8');
    end
end

fclose(fid);

% Read digit labels
fid = fopen(labelFile, 'r', 'b');
header = fread(fid, 1, 'int32');
if header ~= 2049
    error('Invalid label file header');
end
count = fread(fid, 1, 'int32');
if count < readDigits+offset
    error('Trying to read too many digits');
end

if offset > 0
    fseek(fid, offset, 'cof');
end

labels = fread(fid, readDigits, 'uint8');
fclose(fid);

% Calc avg digit and count
% imgs = trimDigits(imgs, 4);
imgs = normalizePixValue(imgs);
%[avg num stddev] = getDigitStats(imgs, labels);

end

function digits = trimDigits(digitsIn, border)
dSize = size(digitsIn);
digits = zeros([dSize(1)-(border*2) dSize(2)-(border*2) dSize(3)]);
for i=1:dSize(3)
    digits(:,:,i) = digitsIn(border+1:dSize(1)-border, border+1:dSize(2)-border, i);
end
end

function digits = normalizePixValue(digits)
digits = double(digits);
for i=1:size(digits, 3)
    digits(:,:,i) = digits(:,:,i)./255.0;
end
end
