function ds = prtDataGenSandP500
% ds = prtDataGenSandP500
%   Return a time-series containing the S&P 500 closing data from 1/3/1950
%   to 5/9/2013.  
%
%   The resulting data set is unlabeled and has data from 15940 days, and 7
%   features, these are 1) the date, 2) the opening value, 3) high value,
%   4) low value, 5) closing value, 6) volume, and 7) adjusted close value.
%
%  Example:   
%     ds = prtDataGenSandP500;
%     plot(ds.X(:,3)) %plot the S&P high value since 1950
%
%   Data retrieved 5/10/2013 from 
%       http://finance.yahoo.com/q/hp?s=%5EGSPC+Historical+Prices
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

spFile = fullfile(prtRoot,'dataGen','dataStorage','sAndP500','sAndP500.csv');
if ~exist(spFile,'file')
    error('prt:MissingData','Could not locate the file %s',spFile);
end

fid = fopen(spFile);
x = textscan(fid,'%s%f%f%f%f%f%f','headerlines',1,'delimiter',',');
fclose(fid);

X = cat(2,datenum(x{1}),x{2},x{3},x{4},x{5},x{6},x{7});
X = flipud(X);
featureNames = {'Date','Open','High','Low','Close','Volume','AdjClose'};
X = flipud(X);
ds = prtDataSetClass(X);
ds.featureNames = featureNames;
