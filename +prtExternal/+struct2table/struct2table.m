%STRUCT2TABLE Display struct content in table format
%   STRUCT2TABLE(S) displays a table with the field names in the headline
%   and one row for each struct element:
%
%   #        [field name 1]         [field name 2] ...
%   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
%   1 S(1).([field name 1])  S(1).([field name 2]) ...
%   2 S(2).([field name 1])  S(2).([field name 2]) ...
%
%   STRUCT2TABLE(S, F) displays only the fields with the names that are
%   contained in the cell-array F.
%
%      If the elements of F itself are also two-element cell arrays (e.g.
%      F{1} = {'field1', 'round'}) individual display modes for each
%      field's values can be set. Until now, two modes have been
%      implemented, both only effective with numbers:
%
%      'normal' - simply the value of the scalar
%      'round'  - the values are rounded before being displayed
%
%      (also see "user parameters" below.)
%
%   STRUCT2TABLE(H, S, F) displays a headline string H before creating the
%   table.
%
%   USER PARAMETERS Some aspects of the layout of the table can be set
%   globally. In detail, the parameters are:
%
%      N_decimal_digits - used to globally set the number of decimal digits
%                         displayed
%                         (applies only to numbers)
%      str_disp_true    - the string used to indicate locigal true
%                         (applies only to logicals)
%      str_disp_false   - the string used to indicate logical false
%                         (applies only to logicals)

%   For complaints, advice or comments in general contact me via
%   faktor.digital.audio@gmail.com
function struct2table(varargin)

% user parameters__________________________________________________________
N_decimal_digits = 2;
str_disp_true = 'yes';
str_disp_false = 'no';
default_parameter = 'round';
% _________________________________________________________________________

% handle the input arguments:
if nargin == 1
    stIn = varargin{1};
elseif nargin == 2
    stIn = varargin{1};
    fieldNames = varargin{2};
elseif nargin == 3
    s_tablename = varargin{1};
    stIn = varargin{2};
    fieldNames = varargin{3};
end

% for use with the MATLAB Compiler:
% (had problems with the "high line" char on the windows console)
if ~isdeployed()
    char_line = '¯';
else
    char_line = '-';
end

if nargin == 3
    % handle the headline...
    L_s_tablename = length(s_tablename);
    fprintf([s_tablename '\n']);
    fprintf([repmat(char_line, 1, L_s_tablename) '\n']);
end

% the number of struct elements
nEntrys = length(stIn);

if (nargin == 1)
    % display all fields...
    fieldNames = fieldnames(stIn);
end
nFields = length(fieldNames);

% determine the column widths by scanning all struct entries...
fprintfArgs = ['''' '#' '''' ','];
formatString = ['%3s'];
for i = 1 : nFields
    cur_fieldName = fieldNames{i};
    if iscell(cur_fieldName)
        % obviously a special field display parameter has been set...
        temp_cell = cur_fieldName;
        cur_fieldName = temp_cell{1};
        cur_parameter = temp_cell{2};
    else
        cur_parameter = default_parameter;
    end
    lengthFieldName = max(getLongestEntry(stIn, cur_fieldName, cur_parameter), length(cur_fieldName));
    formatString = [formatString '   %' num2str(lengthFieldName) 's']; %#ok<AGROW>
    fprintfArgs = [fprintfArgs '''' cur_fieldName '''']; %#ok<AGROW>
    if (i < nFields)
        fprintfArgs = [fprintfArgs ',']; %#ok<AGROW>
    end
end

formatString = [formatString '\n'];

len = eval(['fprintf(' '''' formatString '''' ',' fprintfArgs ');']);
underLine = repmat(char_line, 1, len);
fprintf([underLine '\n']);

% actually print the table:
for i = 1 : nEntrys
    fprintfArgs = ['''' num2str(i) '''' ',' ];
    for j = 1 : nFields
        temp_cell = fieldNames{j};
        if iscell(temp_cell)
            cur_fieldName = temp_cell{1};
            cur_parameter = temp_cell{2};
        else
            cur_fieldName = temp_cell;
            cur_parameter = default_parameter;
        end
        if ischar(stIn(i).(cur_fieldName))
            cur_additional_arg = stIn(i).(cur_fieldName);
        elseif isnumeric(stIn(i).(cur_fieldName))
            switch cur_parameter
                case 'normal'
                    cur_additional_arg = mat2str(stIn(i).(cur_fieldName));
                case 'round'
                    cur_additional_arg = mat2str(round(stIn(i).(cur_fieldName)*10^(N_decimal_digits)) / 10^(N_decimal_digits));
                %case 'sec2time'
                %    cur_additional_arg = sec2time(stIn(i).(cur_fieldName));
            end
        elseif islogical(stIn(i).(cur_fieldName))
            if stIn(i).(cur_fieldName)
                cur_additional_arg = str_disp_true;
            else
                cur_additional_arg = str_disp_false;
            end
        elseif iscell(stIn(i).(cur_fieldName))
            cur_additional_arg = cell2mat(stIn(i).(cur_fieldName));
        end
        fprintfArgs = [fprintfArgs '''' strrep(cur_additional_arg, '''', '''''') '''']; %#ok<AGROW>
        if (j < nFields)
            fprintfArgs = [fprintfArgs ',']; %#ok<AGROW>
        end
    end
    eval(['fprintf(' '''' formatString '''' ',' fprintfArgs ');']);
end

% _________________________________________________________________________
% function to obtain the length of the longest value of a certain field
    function maxLength = getLongestEntry(stIn, fieldName, disp_parameter)
        
        % the number of elements in the struct
        nEntrys = length(stIn);
        lengthOfThisField = 0;
        
        % this loop generates all strings that will show up in the final table
        % later but only uses them to determine their length:
        for sf_counter = 1 : nEntrys
            if (isstruct(stIn(sf_counter).(fieldName)))
                continue;
            end
            if ischar(stIn(sf_counter).(fieldName))
                curLength = length(stIn(sf_counter).(fieldName));
            elseif isnumeric(stIn(sf_counter).(fieldName))
                switch disp_parameter
                    case 'normal'
                        curLength = length(mat2str(stIn(sf_counter).(fieldName)));
                    case 'round'
                        curLength = length(mat2str(round(stIn(sf_counter).(fieldName)*10^(N_decimal_digits)) / 10^(N_decimal_digits)));
                        %case 'sec2time'
                        %    % special display of times...
                        %    curLength = length(sec2time(stIn(sf_counter).(fieldName)));
                end
            elseif islogical(stIn(sf_counter).(fieldName))
                if stIn(sf_counter).(fieldName)
                    curLength = length(str_disp_true);
                else
                    curLength = length(str_disp_false);
                end
            elseif iscell(stIn(sf_counter).(fieldName))
                curLength = length(cell2mat(stIn(sf_counter).(fieldName)));
            else
                warning('this field value type is not yet supported');
            end
            if curLength > lengthOfThisField
                lengthOfThisField = curLength;
            end
        end
        maxLength = lengthOfThisField;
    end % of function "maxLength()"
end % of function "struct2table()"