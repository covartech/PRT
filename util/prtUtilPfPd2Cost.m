function cost = prtUtilPfPd2Cost(pf,pd,costMatrix,priorH0,priorH1)
%cost = prtUtilPfPd2Cost(pf,pd)
%cost = prtUtilPfPd2Cost(pf,pd,costMatrix)
%cost = prtUtilPfPd2Cost(pf,pd,costMatrix,priorH0,priorH1)
%
%   Cost matrix = [0, 1; 1 0];
% xxx Need Help xxx

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
    costMatrix = [0, 1; 1 0];  %equal costs
end
if nargin < 4
    priorH0 = 1/2;
    priorH1 = 1/2;
end
cost = (pd*costMatrix(1,1) + (1-pd)*costMatrix(1,2))*priorH1 + (pf*costMatrix(2,1) + (1-pf)*costMatrix(2,2))*priorH0;
