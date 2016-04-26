function options = prtOptionsGetDefault()
% PRTOPTIONSGETDEFAULT Get the default options for this PRT installation
%   These are options stored as a mat file with name prtOptionsFileName()
%   If this file does not yet exist it is created using
%   prtOptionsSetFactory(). To modify this file use prtOptionsSet() and
%   prtOptionsSetDefault().
%
%   options = prtOptionsGetDefault()
%
% See also. prtOptionsGet, prtOptionsSet, prtOptionsGetDefault
%           prtOptionsSetDefault, prtOptionsGetFactory,
%           prtOptionsSetFactory







optionsFileName = prtOptionsFileName();

if ~exist(optionsFileName,'file');
    % No default options yet, make them from the factory
    options = prtOptionsSetFactory();
else
    Loaded = load(optionsFileName,'options');
    options = Loaded.options;
    
    % Validate that all fields that should be in the options mat file
    % are in the options mat file.
    % You might think that we also have to check to see if all of the
    % necessary properties are in the saved options but you don't. You
    % don't have to because they are MATLAB classes. If the options
    % classes have changed since they were last saved the new
    % properties will be automatically loaded.
    
    loadedFieldNames = fieldnames(options);
    factoryOptions = prtOptionsGetFactory();
    factoryFieldNames = fieldnames(factoryOptions);
    
    newFields = setdiff(factoryFieldNames,loadedFieldNames);
    
    if ~isempty(newFields)
        for iNew = 1:length(newFields)
            options.(newFields{iNew}) = factoryOptions.(newFields{iNew});
        end
        prtOptionsSetDefault(options);
    end
end
