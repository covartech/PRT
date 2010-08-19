function result = prtTestKernelRbf
result = true;

% basic kernel implention, should work

try
    kern = prtKernelRbf;
    kern = kern.initializeBinaryKernel(1);
    result = kern.run(1);
catch
    disp('basic rbf kernel failure')
    result = false;
end

if kern.isInitialized ~= 1
    disp('kernel not initialized')
    result = false;
end

handle = kern.fnHandle;
if ~isa(handle, 'function_handle')
    disp('not a function handle')
    result = false;
end

handleOut = handle(2);
if ~isequal(handleOut, kern.run(2))
    disp('function handle not equal to run')
    result = false;
end

% check higher dim kernel
try
    kern = kern.initializeBinaryKernel([1 2]);
    kernOut = kern.run([ 1 2]);
catch
    disp('higher dim radial basis kernel fail')
    result= false;
end
if kernOut ~=1
    disp('rbf kernel higher dim wrong answer')
    result = false;
end

% check this kernel array nonsense
kern = prtKernelRbf;
dataSet = prtDataSetStandard;
dataSet = dataSet.setX ([1 2]');
kernCell = kern.initializeKernelArray(dataSet);

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