function result = prtTestRVUniform
result = true;

% Test the basic operation
dataSet    = prtDataGenUnimodal;
dataSetOneClass = prtDataSetClass(dataSet.getObservationsByClass(1));

try
    RV = prtRvUniform;                       % Create a prtRVUniform object
    RV = RV.mle(dataSetOneClass.getX);   % Compute the maximum
catch
    disp('prtRVUniform basic operation fail')
    result= false;
end

% % make sure none of these error out
try
    RV.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRVUniform plot pdf fail')
    result = false;
    close
end

RVspec = prtRvUniform;
% % Check that I can specify upper and lower bounds
try
    RVspec.upperBounds = [1 2];  % Spec upper
    RVspec.lowerBounds = [-2 -2] ;    % Specify lower
catch
    disp('prtRVUniform  upper lower set fail')
    result=  false;
end

%check the draw function
try
    sample = RVspec.draw(1);
catch
    disp('prtRVUniform draw fail')
    result = false;
end

if( size(sample) ~= [1 2])
    disp('prtRVUniform sample size incorrect')
    result = false;
end

% check the pdf and cdf functions
try
    val1 = RV.pdf([ 0 0 ]);
    %val2 = RV.cdf([ 0 0]); % Cdf does not work in 2D
catch
    disp('prtRVUniform pdf/cdf fail')
    result = false;
end

% Make sure we error out on size mismatch
try
    val1 = RV.pdf(0);
    val2 = RV.cdf(0);
    disp('prtRVUniform pdf/cdf size check fail')
    result = false;
catch
    % noop;
end


try
    RV = prtRvUniform;
    RV.upperBounds = [ 1 1];
    RV.lowerBounds = [ 2 3];
    
    % This is legitimate to do although at this point the RV is not valid.
    % Attempting to do anything else will result in an error and a nice
    % message telling you why. I modified this test to check if we actually
    % think isValid = true. 
    if RV.isValid 
        disp('prtRVuniform lower higher than upper')
        result = false;
    end
catch
    % noop
end
