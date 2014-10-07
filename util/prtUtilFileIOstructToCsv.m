function prtUtilFileIOstructToCsv(csvFile,structure,theFieldNames)
%prtUtilFileIOstructToCsv(csvFile,structure)
%
%   Write a M x 1 structure to a csvFile
%
%prtUtilFileIOstructToCsv(csvFile,structure,theFieldNames)
%
%   Write a M x 1 structure to a csvFile using only the fields specified in
%   theFieldNames
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


if nargin < 3
    theFieldNames = fieldnames(structure);
end

fid = fopen(csvFile,'w');

c = onCleanup(@()closeFid(fid));
if fid < 0
    error('Unable to open file %s',fileName);
end

%write header line:
fprintf(fid,'%s,',theFieldNames{:});
fseek(fid,-1,0); %go back one byte (comma)
fprintf(fid,'\n');

%For each structure, and each field, get the field; determine the field
%type, then print it, followed by a comma
for structInd = 1:length(structure)
    currStruct = structure(structInd);
    for fieldInd = 1:length(theFieldNames)
        currField = currStruct.(theFieldNames{fieldInd});
        if isa(currField,'char')
            fprintf(fid,'%s,',currField);
        else
            fprintf(fid,'%f,',currField);
        end
    end
    fseek(fid,-1,0); %go back one byte (comma)
    fprintf(fid,'\n');
end

closeFid(fid)

    function closeFid(fid)
        try
            fclose(fid);
        catch ME %#ok<NASGU>
            %Hide the error
        end
    end

end
