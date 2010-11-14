function result = prtTestDiscreteMultinomial
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
    RVd.probabilities = [.1 .2 .7];
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
    RVd.symbols = [1 2 3];
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

% check the pdf and cdf functions
try
    val1 = RVd.pdf([ 0 0 ]);
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
