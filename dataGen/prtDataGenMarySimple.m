function DataSet = prtDataGenMarySimple(nSamples)
% prtDataGenMary  Generate unimodal M-ary example data
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




if nargin < 1
    nSamples = 100;
end
rvH1 = prtRvMvn('mu',[0 0],'sigma',1*eye(2));
rvH2 = prtRvMvn('mu',[2 2],'sigma',1*eye(2));
rvH3 = prtRvMvn('mu',[4 0],'sigma',eye(2));
X = cat(1,draw(rvH1,nSamples),draw(rvH2,nSamples),draw(rvH3,nSamples));
Y = prtUtilY(0,nSamples,nSamples,nSamples);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenMary');
