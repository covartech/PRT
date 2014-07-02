function YamlStruct = ReadYamlFromString(inputString)
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

import prtExternal.yaml.*;

%InitYaml();
packagePath = fullfile(prtRoot,'+prtExternal','+yaml','YAMLMatlab','external-packages','snakeyaml');
jarPath = fullfile(packagePath,'snakeyaml-1.8.jar');

v = strfind(javaclasspath,packagePath);
if isempty(v) || isempty(v{1})
    javaaddpath(jarPath)
end
import('org.yaml.snakeyaml.Yaml');

yamlreader = Yaml();
yml = inputString;

jymlobj = yamlreader.load(yml);

Data = Hash2Struct(jymlobj);
% work_folder=fileparts(yaml_file);
% if isfield(Data,'import')
%     yml = '';
%     for i=1:numel(Data.import)
%         fToImport= fullfile(work_folder,Data.import{i});
%         try
%             fxx=fileread(fToImport);
%             yml=sprintf('%s\n%s',yml,  fxx);
%         catch %#ok<CTCH>
%             warning('YAMLMatlab:FileNotFoundException','YAMLMatlab: File %s not found',fToImport);
%         end        
%     end
%     jymlobj = yamlreader.load(yml);
%     YamlStruct = Hash2Struct(jymlobj);
% else
    YamlStruct = Data;
% end
