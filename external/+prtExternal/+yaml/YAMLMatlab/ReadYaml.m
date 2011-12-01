function YamlStruct = ReadYaml(yaml_file)
% This function reads Yaml file into struct
% Example
% >> yaml_file = 'EnaspolMain.yaml';
% >> YamlStruct = ReadYaml(yaml_file)
%
%  %======================================================================
%{
		Copyright (c) 2011
		This program is a result of a joined cooperation of Energocentrum
		PLUS, s.r.o. and Czech Technical University (CTU) in Prague.
        The program is maintained by Energocentrum PLUS, s.r.o. and
        licensed under the terms of MIT license. Full text of the license
        is included in the program release.
		
        Author(s):
		Jiri Cigler, Dept. of Control Engineering, CTU Prague 
		Jan  Siroky, Energocentrum PLUS s.r.o.
		
        Implementation and Revisions:

        Auth  Date        Description of change
        ----  ---------   -------------------------------------------------
        jc    01-Mar-11   First implementation
        jc    02-Mar-11   .jar package initialization moved to external fun
        jc    18-Mar-11   Warning added when imported file not found
%}
%======================================================================

InitYaml();

import('org.yaml.snakeyaml.Yaml');

yamlreader = Yaml();
yml = fileread(yaml_file);
jymlobj = yamlreader.load(yml);

Data = Hash2Struct(jymlobj);
work_folder=fileparts(yaml_file);
if isfield(Data,'import')
    yml = '';
    for i=1:numel(Data.import)
        fToImport=[work_folder filesep Data.import{i}];
        try
            fxx=fileread(fToImport);
            yml=sprintf('%s\n%s',yml,  fxx);
        catch
            warning('YAMLMatlab:FileNotFoundException','YAMLMatlab: File %s not found',fToImport);
        end        
    end
    jymlobj = yamlreader.load(yml);
    YamlStruct = Hash2Struct(jymlobj);
else
    YamlStruct  =Data;
end
end % end of function


