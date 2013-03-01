function result = prtTestDiscreteMultinomial

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
dataSet    = prtDataGenUnimodal;
dataSetOneClass = floor(prtDataSetClass(dataSet.getObservationsByClass(1)).getX);

try
    RVd = prtRvDiscrete;                       % Create a prtRvDiscrete object
    RVd = RVd.mle(dataSetOneClass);   % Compute the maximum
catch
    disp('prtRvDiscrete basic operation fail')
    result= false;
end


try
    RVm = prtRvDiscrete;                       % Create a prtRvMultinomial
    RVm = RVm.mle(dataSetOneClass);   % Compute the maximum
catch
    disp('prtRvDiscrete basic operation fail')
    result= false;
end


% make sure none of these error out
try
    RVd = prtRvDiscrete;
    RVd.symbols = [ 1 2 3]';
    RVd.probabilities = [.1 .2 .7]';
    RVd.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRvDiscrete plot pdf fail')
    result = false;
    close
end

% make sure none of these error out
try
    RVm = prtRvMultinomial;
    RVm.probabilities = [.1 .2 .7];
    RVm.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRvMultinomial plot pdf fail')
    result = false;
    close
end


% Check that the probablity vector must sum to 1
try
    RVd = prtRvDiscrete;
    RVd.probabilities = [.1 .2 .9];
    disp('prtRvDiscrete prob vector sum fail')
    result = false;
catch
    % no-op
end


% Check that the probablity vector must sum to 1
try
    RVm = prtRvMultinomial;
    RVm.probabilities = [.1 .2 .9];
    disp('prtRvMultinomial prob vector sum fail')
    result = false;
catch
    % no-op
end

% check the draw function
try
    RVd.symbols = [ 1 2 3]';
    RVd.probabilities = [.1 .2 .7];
    
    RVm = prtRvMultinomial;
    RVm.probabilities = [.1 .2 .7];
    sample1 = RVd.draw(1);
    sample2 = RVm.draw(1);
catch
    disp('prtRvDiscMult draw fail')
end

if( size(sample1) ~= [1 2])
    disp('prtRvDiscrete sample size incorrect')
    result = false;
end

if( size(sample2) ~= [1 2])
    disp('prtRvMultinomial sample size incorrect')
    result = false;
end

% Check that we can set the symbols for the prtRvDiscrete
try
    RVd.symbols = [1 2 3]';
catch
    disp('prtRvDiscrete symbol set fail')
    result = false;
end

% Check dims
try
    RVd.symbols = [1 2 ];
    disp('prtDiscrete wrong # of symbols fail')
    result = false;
catch
    % noop
end

% Check that they are numeric
try
    RVd.symbols = ['a','b','c'];
    disp('prtRvDiscrete symbol set to strings')
    result = false;
catch
    %no-op
end
%
% check the pdf and cdf functions
try
    val1 = RVd.pdf([1 2 3 ]');
    val2 = RVm.pdf([1 0 0; 0 1 0; 0 0 1]);
catch
    disp('prtRvDiscrete pdf/cdf fail')
    result = false;
end

if(~ isequal(val1,[.1 .2 .7]'))
    disp('prtRvDiscrete pdf wrong val')
    result = false;
end

if(~ isequal(val2,[.1 .2 .7]'))
    disp('prtRvMultinomial pdf wrong val')
    result = false;
end


% Make sure we error out on size mismatch
try
    val1 = RVd.pdf([1 2]);
    val2 = RVm.cdf([1 2 3]);
    disp('prtRvDiscreteMultinomial pdf/cdf size check fail')
    result = false;
catch
    % noop;
end

% Make sure we dont operate on an invalid RV
try
    
    RVd = prtRvDiscrete;
    RVd.symbols = [ 1 2 3];
    RVd.plotPdf                           % Plot the pdf
    RVd.pdf(1);
    RVd.draw(1);
    disp('prtRvDiscrete operationg on invalid RV')
    result = false;
    
catch
    % no-op
end


% Should error out on non-count matrix input
% I decided that it shouldn't error - KDM 2013-03-01
% try
%     RV = prtRvMultinomial;
%     Y = [ 1 2 3; 4 5 6];
%     RV = mle(RV,Y);
%     disp('prtRvMultinomial non-count matrix input');
%     result = false;
% catch
%     % no-op
% end
