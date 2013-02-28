function result = prtTestRvVq

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
dataSet = prtDataGenUnimodal;        % Load a dataset consisting of
                                        % 2 features
   dataSet = retainFeatures(dataSet,1); % Retain only the first feature
 
try
    RV = prtRvVq;
    RV = RV.mle(dataSet);   % Compute the maximum
catch
    disp('prtRvVq basic operation fail')
    result= false;
end

% make sure none of these disp out
try
    RV.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRvVq plot pdf fail')
    result = false;
    close
end

RVspec = prtRvVq;
% Check that I can specify params
try
    RVspec.probabilities = [.4 .6];
    RVspec.means = [ 2 4]';
catch
    disp('prtRvVq mean prob set fail')
    result=  false;
end

if ~isequal(RVspec.nCategories,2)
    disp('prtRvVq wrong number categories')
    result=  false;
end

try
 RVspec.means =  [2 2; 3 3];
catch
    disp('prtRvVq higher order means fail')
    result = false;
end

% check the draw function
sample = [];
try
    sample = RVspec.draw(1);
catch
    disp('prtRvVq draw fail')
    result = false;
end

if( size(sample) ~= [1 2])
    disp('prtRvVq sample size incorrect')
    result = false;
end


% check the pdf and cdf functions
try
    val1 = RVspec.pdf([ 0 0 ]);
  % val2 = RVspec.cdf([ 0 0]); % Cdf does not work in 2D
catch
    disp('prtRvVq pdf/cdf fail')
    result = false;
end

% Make sure we error out on size mismatch
try
    val1 = RVspec.pdf(0);
    val2 = RVspec.cdf(0);
    disp('prtRvVq pdf/cdf size check fail')
    result = false;
catch
    % noop;
end

