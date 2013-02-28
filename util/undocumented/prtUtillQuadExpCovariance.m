function K = prtUtillQuadExpCovariance(x1, x2, theta0, theta1, theta2, theta3)
% xxx Need Help xxx
% K = prtUtillQuadExpCovariance(x1, x2, theta0, theta1, theta2, theta3)
%
% Common covariance function for Gaussian Processes
%
% Bishop, Pattern Recognition and Machine Learning Eq. 6.63

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


if nargin < 6 || isempty(theta3)
    theta3 = 0;
end

if nargin < 5 || isempty(theta2)
    theta2 = 0;
end

if nargin < 4 || isempty(theta1)
    theta1 = 1;
end

if nargin < 3 || isempty(theta0)
    theta0 = 1;
end

K = theta0 * exp(-theta1/2 * prtDistanceEuclidean(x1,x2).^2) + theta2 + theta3*x1*x2';
