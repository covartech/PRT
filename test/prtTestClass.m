function result = prtTestClass
% This function will check basic object construction and management
result = true;


%% Object contruction error checks
error = true;  % We will want all these things to error

classifier = prtClassMAP;

try
    classifier.name = 'sam';
    error = false;  % Set it to false if the preceding operation succeeded
catch
    % do nothing
    % We can potentially catch and check the error string here
    % For now, just be happy it is erroring out.
end

try
    classifier.nameAbbreviation = 'sam';
    error = false;
catch
    % do nothing
end

try
    classifier.isSupervised = 1;
    error = false;
catch
    % do nothing
end

try
    classifier.isMary = 1;
    error = false;
catch
    % do nothing
end

try
    classifier.yieldsMaryOutput = 1;
    error = false;
catch
    % do nothing
end

try
    classifier.twoClassParadigm = 'sam';
    error = false;
catch
    % do nothing
end

try
    classifier.DataSet = 2;
    error = false;
catch
    % do nothing
end

%% XXX This should error out
% try
%     classifier.verboseStorage = 'sam'; 
%     error = false;  
% catch
%     % do nothing
% end

%%
% Object construction non-errors
% We want these to be settable

noerror = true;

try
    classifier.UserData = 'sam';   
catch
    noerror = false;
end

try
    classifier.verboseStorage = 0;   
catch
    noerror = false;
end

try
    classifier.PlotOptions = prtClassPlotOpt;   
catch
    noerror = false;
end

result = result & error & noerror;