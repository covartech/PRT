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

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


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
