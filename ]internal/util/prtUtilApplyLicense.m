function prtUtilApplyLicense(fileName,doIt)
% prtUtilApplyLicense(fileName)
%   Used internaly to update license information in the PRT
%
%  Uses prtUtilLicense to get the right license string.
%  Ignores files containing prtExternal or prtDoc.
%  Ignores files that already have "% Copyright (c) 2013 New Folder Consulting" in
%  them.
%  May duplicate copyrights in other files, so be careful.
%  When we update the license file, we need to write prtUtilRemoveLicense
%
%  Edit this M-file to see how to call it to make it actually do something.
%   This functionality is too dangerous to DOC.  Just edit the M-file and
%   poke around.

% To make it do something, make doIt true...

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


% g = subDir(prtRoot,'*.m');
% for i = 1:length(g); prtUtilApplyLicense(g{i}); end

if nargin < 2
    doIt = false;
end

if ~isempty(strfind(lower(fileName),'prtexternal'))
    [p,f] = fileparts(fileName);
    fprintf('prtExternal file ignored: %s (in %s)\n',p,f);
    return;
end
if ~isempty(strfind(lower(fileName),'prtdoc'))
    [p,f] = fileparts(fileName);
    fprintf('prtDoc file ignored: %s (in %s)\n',f,p);
    return;
end 

newStr = '';
licenseStr = prtUtilLicense;

fid = fopen(fileName);
s = fscanf(fid,'%c');
fclose(fid);

if ~isempty(strfind(s,'% Copyright (c) 2013 New Folder Consulting'))
    fprintf('NFC Copyright already in: %s (Ignoring)\n',f);
    return;
end
if ~isempty(strfind(lower(s),'copyright'))
    [p,f] = fileparts(fileName);
    fprintf('Copyright found in: %s (OK if it doesn''t conflict with ours)\n',f);
    %     edit(fileName);
end

fid = fopen(fileName);
cLine = fgetl(fid);
newStr = cLine; %always start with the first string, now:

startFound = false;
while ~startFound & ~feof(fid);
    cLine = fgetl(fid);
    cLineDeblank = strtrim(cLine);
    
    if length(cLineDeblank) > 0 && cLineDeblank(1) == '%';
        startFound = false;
        newStr = sprintf('%s\n%s',newStr,cLine);
    else
        startFound = true;
        if length(cLineDeblank) == 0
            cLine = '';
        end
    end
end

newStr = sprintf('%s\n\n%s\n%s\n',newStr,licenseStr,cLine);

while ~feof(fid)
    cLine = fgetl(fid);
    newStr = sprintf('%s\n%s',newStr,cLine);
end
newStr = sprintf('%s\n',newStr);
fclose(fid);

if doIt
    fOut = fopen(fileName,'w');
    fprintf(fOut,'%s',newStr);
    fclose(fOut);
else
    disp('Not doing anything; see the help');
end
