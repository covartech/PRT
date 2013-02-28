function [ds,allClasses] = prtDataGenMsrcorid(classList)
%   prtDataGenMsrcorid Read in data from the Microsoft Research Cambridge
%       Object Recognition Database (MSRCORID)
%
%   ds = prtDataGenMsrcorid generates a prtDataSetCellArray containing
%   data from the MSRCORID database.  To obtain the database, please
%   download it from 
%       http://research.microsoft.com/en-us/downloads/b94de342-60dc-45d0-830b-9f6eff91b301/default.aspx
%   And extract it to: 
%       fullfile(prtRoot,'dataGen','dataStorage','msrcorid');
% 
%   So that:
%       fullfile(prtRoot,'dataGen','dataStorage','msrcorid','flowers')
% 
%   points to a valid directory.
%
%   By default prtDataGenMsrcorid returns images from the "flowers\single"
%   and "chimneys" classes only.
%
%   ds = prtDataGenMsrcorid(classList) gets data from the classes specified
%   in the cell array classList.  classList should be a list of
%   sub-directories inside the MSRCORID directory.  For example,
%
%    ds = prtDataGenMsrcorid({'flowers\single','chimneys'}) 
% 
%   outputs the data corresponding to the chimney and flowers\single
%   classes, which are both valid sub-directories of the MSRCORID data on a
%   Windows computer.
%
%   ds = prtDataGenMsrcorid(classList,nSamples) returns at most nSamples
%   from each class.
%
%   [ds,allClasses] = prtDataGenMsrcorid(...) also outputs a complete list
%   of all the class designations from the MSRCORID.
%
%   Note that the output of prtDataGenMsrcorid is a prtDataSetCellArray.
%
%   % Example:
%   ds = prtDataGenMsrcorid;
%   imshow(ds.X{1});

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



prtPath('beta')
baseDir = fullfile(prtRoot,'dataGen','dataStorage','msrcorid');
if ~exist(baseDir,'dir')
    error('prt:MissingData','Could not locate the MSRCORID database in the folder %s; please download the database and extract it from here: http://research.microsoft.com/en-us/downloads/b94de342-60dc-45d0-830b-9f6eff91b301/default.aspx',baseDir);
end

if nargin < 1
    classList = {fullfile('flowers','single'),'chimneys'};
end
if ~isa(classList,'cell')
    classList = {classList};
end

allClasses = {'aeroplanes\general','aeroplanes\single','animals\cows\general','animals\cows\single','animals\sheep\general','animals\sheep\single',...
    'benches_and_chairs','bicycles\general','bicycles\side view, single','birds\general','birds\single','buildings','cars\front view','cars\general','cars\rear view','cars\side view',...
    'chimneys','clouds','doors','flowers\general','flowers\single','kitchen_utensils\forks','kitchen_utensils\knives','kitchen_utensils\spoons','leaves','miscellaneous',...
    'scenes\countryside','scenes\office','scenes\urban','signs','trees\general','trees\single','windows'};

allClasses = strrep(allClasses,'\',filesep);

if strcmpi(classList{1},'all')
    classList = allClasses;
end

if nargin < 2
    maxNumExamplesPerClass = inf;
end
resizeFact = .5;
imgCell = cell(length(classList),1);
for i = 1:length(classList)
    cDir = fullfile(baseDir,classList{i});
    if ~exist(cDir,'dir')
        error('prt:MissingData','Could not locate the MSRCORID sub-folder %s',cDir);
    end

    fList = subDir(cDir,'*.jpg');
    
    imgCell{i} = cell(min([maxNumExamplesPerClass,length(fList)]),1);
    for imgInd = 1:min([maxNumExamplesPerClass,length(fList)]);
        img = imread(fList{imgInd});
        img = imresize(img,resizeFact);
        imgCell{i}{imgInd,1} = img;
    end
end

x = cat(1,imgCell{:});
y = prtUtilY(cellfun(@(c)length(c),imgCell));
ds = prtDataSetCellArray(x,y);
ds.classNames = classList;
