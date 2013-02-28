function result = prtTestRvMvn

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
result = true;


% Test the basic operation
dataSet    = prtDataGenUnimodal(500);
dataSetOneClass = prtDataSetClass(dataSet.getObservationsByClass(1));

try
    RV = prtRvMvn;                       % Create a prtRvMvn object
    RV = RV.mle(dataSetOneClass.getX);   % Compute the maximum
catch
    disp('prtRvMvn basic operation fail')
    result= false;
end

if any(abs(RV.mu - [2 2] ) > .1)
    result = false;
end
% make sure none of these disp out
try
    RV.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRvMvn plot pdf fail')
    result = false;
    close
end

RVspec = prtRvMvn;
% Check that I can specify the mean and covar
try
    RVspec.mu = [1 2];                 % Specify the mean
    RVspec.sigma = [2 -1; -1 2] ;    % Specify the covariance
catch
    disp('prtRvMvn mean covar set fail')
    result=  false;
end

% check the draw function
try
    sample = RVspec.draw(1);
catch
    disp('prtRvMvn draw fail')
    result = false;
end

if( size(sample) ~= [1 2])
    disp('prtRvMvn sample size incorrect')
    result = false;
end

% Check that we can set the covar structure
try
    RV.covarianceStructure = 'Full';
    RV.covarianceStructure = 'Spherical';
    RV.covarianceStructure = 'Diagonal';
catch
    disp('prtRvMvn covar structure set fail')
    result = false;
end

% Add a check here to make sure the covar is actually diagonal
if ~isequal(RV.sigma, diag(diag(RV.sigma),0))
    disp('prtRvMvn covariance not diagonal')
    result = false;
end

% check the pdf and cdf functions
try
    val1 = RV.pdf([ 0 0 ]);
    %val2 = RV.cdf([ 0 0]); % Cdf does not work in 2D
catch
    disp('prtRvMvn pdf/cdf fail')
    result = false;
end

% Make sure we error out on size mismatch
try
    val1 = RV.pdf(0);
    val2 = RV.cdf(0);
    disp('prtRvMvn pdf/cdf size check fail')
    result = false;
catch
    % noop;
end

