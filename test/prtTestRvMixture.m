function result = prtTestRvMixture
result = true;

% Test the basic operation      
ds = prtDataGenOldFaithful;      % Load a data set

try
    RV = prtRvMixture('components',repmat(prtRvMvn,1,2));
    RV = RV.mle(ds);   % Compute the maximum
catch
    disp('prtRvMixture basic operation fail')
    result= false;
end

% make sure none of these disp out
try
    RV.plotPdf                           % Plot the pdf
    close
catch
    disp('prtRvMixture plot pdf fail')
    result = false;
    close
end

RVspec = prtRvMixture('components',repmat(prtRvMvn,1,2));
% Check that I can specify the mean and covar
try
    RVspec.components(1).mean = [1 2];                 % Specify the mean
    RVspec.components(1).covariance = [2 -1; -1 2] ;    % Specify the covariance
    RVspec.components(2).mean = [1 2];                 % Specify the mean
    RVspec.components(2).covariance = [2 -1; -1 2] ;    % Specify the covariance
catch
    disp('prtRvMixture mean covar set fail')
    result=  false;
end

% check the draw function
sample = [];
try
    sample = RVspec.draw(1);
catch
    disp('prtRvMixture draw fail')
    result = false;
end

if( size(sample) ~= [1 2])
    disp('prtRvMixture sample size incorrect')
    result = false;
end


% check the pdf and cdf functions
try
    val1 = RVspec.pdf([ 0 0 ]);
   % val2 = RVspec.cdf([ 0 0]); % Cdf does not work in 2D
catch
    disp('prtRvMixture pdf/cdf fail')
    result = false;
end

% Make sure we error out on size mismatch
try
    val1 = RVspec.pdf(0);
    val2 = RVspec.cdf(0);
    disp('prtRvMixture pdf/cdf size check fail')
    result = false;
catch
    % noop;
end

