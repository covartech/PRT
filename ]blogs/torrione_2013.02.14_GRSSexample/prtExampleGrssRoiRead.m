function roiStruct = prtExampleGrssRoiRead(roiTxtFile)

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


if nargin < 1
    roiTxtFile = 'C:\Users\pete\Documents\data\2013IEEE_GRSS_DF_Contest\2013_IEEE_GRSS_DF_Contest_Samples_TR.txt';
end

fid = fopen(roiTxtFile,'r');
s = fscanf(fid,'%c');
fclose(fid);

startIndices = strfind(s,'; ROI name:');

for i = 1:length(startIndices)
    if i < length(startIndices)
        next = startIndices(i+1);
    else
        next = length(s);
    end
    remStr = s(startIndices(i):next);
    
    [temp,pos] = textscan(remStr,'%s %s %s %s',1);
    roiName{i} = temp{end}{1};

    [temp,pos2] = textscan(remStr(pos+1:end),'%s %s %s %s %s%s%s',1);
    roiRgb{i} = sprintf('%s%s%s',temp{end-2}{1},temp{end-1}{1},temp{end}{1});
    
    [temp,pos3] = textscan(remStr(pos+pos2+1:end),'%s %s %s %s',1);
    nPoints{i} = str2num(temp{end}{1});

    [temp,pos4] = textscan(remStr(pos+pos2+pos3+1:end),'%s %s %s %s %s %s',1);
    
    mat = textscan(remStr(pos+pos2+pos3+pos4+1:end),'%d %d %d %f %f',nPoints{i});

    locsXy{i} = cat(2,mat{2:3});
    locsLatLon{i} = cat(2,mat{4:5});
end
roiStruct = struct('name',roiName,'rgb',roiRgb,'nPoints',nPoints,'xy',locsXy,'latLon',locsLatLon);
