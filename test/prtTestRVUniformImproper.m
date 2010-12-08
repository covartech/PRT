function result = prtTestRVUniformImproper
result = true;

% Test the basic operation
dataSet    = prtDataGenUnimodal;
dataSetOneClass = prtDataSetClass(dataSet.getObservationsByClass(1));

try
    RV = prtRvUniformImproper;                       % Create a prtRVUniformImproper object
    RV = RV.mle(dataSetOneClass.getX);   % Compute the maximum
catch
    disp('prtRVUniformImproper basic operation fail')
    result= false;
end

% % make sure none of these error out
try
    RV.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRVUniformImproper plot pdf fail')
    result = false;
    close
end

RVspec = prtRvUniformImproper;
% % Check that I can specify the number of dimensions
try
  error;
catch
    disp('prtRVUniformImproper  nDims set fail')
    result=  false;
end

%check the draw function
try
    sample = RV.draw(1);
catch
    disp('prtRVUniformImproper draw fail')
    result = false;
end

if( size(sample) ~= [1 1])
    disp('prtRVUniformImproper sample size incorrect')
    result = false;
end

% check the pdf and cdf functions
val1 = [];
try
    val1 = RV.pdf([ 0 0 ]);
    %val2 = RV.cdf([ 0 0]); % Cdf does not work in 2D
catch
    disp('prtRVUniformImproper pdf/cdf fail')
    result = false;
end

if ~isequal(val1,1)
    disp('prtRvUniformImproper pdf not 1')
    result = false;
end

% Make sure we error out on size mismatch
try
    val1 = RV.pdf([0]);
    val2 = RV.cdf([0]);
    disp('prtRVUniformImproper pdf/cdf size check fail')
    result = false;
catch
    % noop;
end
