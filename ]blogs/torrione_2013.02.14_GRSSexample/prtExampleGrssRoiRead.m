function roiStruct = prtExampleGrssRoiRead(roiTxtFile)

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
