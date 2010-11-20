function result = prtTestRvGmm
result = true;

% Test the basic operation      
ds = prtDataGenOldFaithful;      % Load a data set

try
    RV = prtRvGmm('nComponents',2); 
    RV = RV.mle(ds);   % Compute the maximum
catch
    disp('prtRvGmm basic operation fail')
    result= false;
end

% make sure none of these disp out
try
    RV.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRvGmm plot pdf fail')
    result = false;
    close
end

RVspec = prtRvGmm('nComponents',2);
% Check that I can specify the mean and covar
try
    RVspec.components(1).mean = [1 2];                 % Specify the mean
    RVspec.components(1).covariance = [2 -1; -1 2] ;    % Specify the covariance
        RVspec.components(2).mean = [1 2];                 % Specify the mean
    RVspec.components(2).covariance = [2 -1; -1 2] ;    % Specify the covariance
catch
    disp('prtRvGmm mean covar set fail')
    result=  false;
end

% check the draw function
sample = [];
try
    sample = RVspec.draw(1);
catch
    disp('prtRvGmm draw fail')
    result = false;
end

if( size(sample) ~= [1 2])
    disp('prtRvGmm sample size incorrect')
    result = false;
end

% Check that we can set the covar structure
try
    RV.covarianceStructure = 'Full';
    RV.covarianceStructure = 'Spherical';
    RV.covarianceStructure = 'Diagonal';
catch
    disp('prtRvGmm covar structure set fail')
    result = false;
end

% check the pdf and cdf functions
try
    val1 = RVspec.pdf([ 0 0 ]);
   % val2 = RVspec.cdf([ 0 0]); % Cdf does not work in 2D
catch
    disp('prtRvGmm pdf/cdf fail')
    result = false;
end

% Make sure we error out on size mismatch
try
    val1 = RVspec.pdf(0);
    val2 = RVspec.cdf(0);
    disp('prtRvGmm pdf/cdf size check fail')
    result = false;
catch
    % noop;
end

