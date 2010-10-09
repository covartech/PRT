function result = prtTestKernelRbf
result = true;

% basic kernel implention, should work

try
    kern = prtKernelRbf;
    kern = kern.trainKernel(1);
    result = kern.evalKernel(1);
catch
    disp('basic rbf kernel failure')
    result = false;
end

% check higher dim kernel
try
    kern = kern.trainKernel([1 2]);
    kernOut = kern.evalKernel([ 1 2]);
catch
    disp('higher dim radial basis kernel fail')
    result= false;
end
if kernOut ~=1
    disp('rbf kernel higher dim wrong answer')
    result = false;
end

% check to string
try
    str = kern.toString;
catch
    disp('rbf kern toString fail')
    result = false;
end
if ~isa(str, 'char')
    disp('rbf kernel toString not a string')
    result = false;
end

% check this kernel array nonsense
kern = prtKernelRbf;
dataSet = prtDataSetStandard;
dataSet = dataSet.setX ([1 2]');
kernCell = prtKernel.sparseKernelFactory(kern,dataSet,1:dataSet.nObservations);

if (kernCell{1}.run(1) ~=1) || (kernCell{2}.run(2) ~=1)
    disp('kernel array error')
    result = false;
end


%% Erorr checks
error = true;
% Check that it errors out when not initialized
kern = prtKernelRbf;
try
    kern.run(1);
    disp('rbf kernel run before init')
    error = false;
catch
    %% 
end
result = result && error;