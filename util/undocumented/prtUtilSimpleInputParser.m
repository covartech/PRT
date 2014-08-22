function [optionsOut, inputParserObj] = prtUtilSimpleInputParser(options, vararginCell)
% prtUtilSimpleInputParser - A simpler way to use inputParser.
%   Takes in an options structure and a cell of other inputs.
%   Builds the input perser and returns the results.
%   Does only basic things, checking for names.
%   No error checking for data types etc. If you need more advanced
%   inputParser behavior you should just use it directly.
%   
% Example:
%   options.a = 1;
%   options.b = 'two';
%   optionsOut = prtUtilSimpleInputParser(options,{'a',100});

inputParserObj = inputParser;

inputParserObj.CaseSensitive = false;
inputParserObj.KeepUnmatched = false;

fields = fieldnames(options);
for iField = 1:length(fields)
    addParameter(inputParserObj,fields{iField},options.(fields{iField}));
end

parse(inputParserObj, vararginCell{:})

optionsOut = inputParserObj.Results;

