function result = prtTestKernelPolynomial
result = true;

% basic kernel implention, should work

try
    kern = prtKernelPolynomial;
    ds = prtDataGenBimodal;
    kern = kern.train(ds);
    kernOut = kern.run(ds);
catch ME
    disp(ME)
    disp('basic polynomial kernel failure')
    result = false;
end

% Check that i can set params
try
    kern.d = 1;
    kern.c = 2;
    kern = kern.train(ds);
    kernOut = kern.run(ds);
catch ME
    disp(ME)
    disp('polynomial kernel fail')
    result = false
end


kern.d = 2; kern.c = 0;
ds = prtDataSetClass;
ds = ds.setObservations([1 2 3]');
kern = kern.train(ds);
kernOut = kern.run(ds);
if kernOut.getX ~= [ 1 4 9; 4 16 36; 9 36 81]
    disp('poly kern wrong output')
    result = false;
end

% check to string
try
    str = kern.toString;
catch ME
    disp(ME)
    disp('poly kern toString fail')
    result = false;
end
if ~isa(str, 'char')
    disp('poly kernel toString not a string')
    result = false;
end


%% Erorr checks
error = true;
% Check that it errors out when not initialized
kern = prtKernelPolynomial;
try
    kern.run(1);
    disp('poly kernel run before init')
    error = false;
catch
    %%
end
result = result && error;