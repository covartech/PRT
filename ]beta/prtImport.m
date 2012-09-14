classdef prtImport
    % Import Data from CSV, MAT files:
    %
    % p = prtImport;
    % ds = p.import(csvFile);
    %
    % For CSV files, tries to handle:
    %   Header lines, numeric and string-valued columns, 'nan' and empty
    %   regions as NaN.
    %
    % For MAT files:
    %   If mat file has a data set, use that
    %   Otherwise, if mat file has x, look for y, and use x & y
    %   Otherwise, if mat file has data, look for targets, and use data &
    %   targets
    
    properties
        theDataSet
    end
    
    methods
        function self = prtImport(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function ds = import(self,theFile,fileSpec)
            
            [p,f,e] = fileparts(theFile);
            
            switch e
                case ''
                    disp('No extension... this is hard');
                case {'.txt','.csv','.xls'}
                    % Algo: 
                    %   1) Figure out if it has a header line
                    %   2) Read rest of data
                    
                    % structure comes out as an Nx1 struct, but should
                    % really be a 1x1 struct with N-dim fields.  Todo: add
                    % parameter to csvToStructure, "compressed" which
                    % passes through to csvCellToStructure, and switches
                    % the way the struct gets made
                    [structure,nonNumericFields] = prtUtilImportCsvToStructure(theFile);
                    
                    fields = fieldnames(structure);
                    x = nan(length(structure),length(fields));
                    featureInfo = repmat(struct('uStrings',[]),length(fields),1);
                    for i = 1:length(fields);
                        if any(strcmpi(nonNumericFields,fields{i}))
                            %handle string values
                            [inds,uStrings] = prtUtilStringsToClassNumbers({structure.(fields{i})});
                            x(:,i) = inds;
                            featureInfo(i).uStrings = uStrings;
                        else
                            x(:,i) = cat(1,structure.(fields{i}));
                        end
                    end
                    
                    ds = prtDataSetClass(x);
                    if ~isempty(nonNumericFields)
                        ds.featureInfo = featureInfo;
                    end
                    ds.featureNames = fields;
                    
                    ds = userChooseTargetVariable(self,ds);
                    
                case '.mat'
                    disp('Easy!');
                    % Algo:
                    %   1) Has a prtDataSetClass?  OK!
                    %   2) Has X and Y?  OK!
                    %   3) Has data and labels?  OK!
                    %   4) Has one variable?  OK!
                    %
                    % Otherwise, ask
                    variables = whos('-file',theFile);
                    if any(strcmpi({variables.class},'prtDataSetClass'))
                        found = find(strcmpi({variables.class},'prtDataSetClass'));
                        variables(found(1)).name

                        loadStruct = load(theFile,variables(found(1)).name);
                        ds = loadStruct.(variables(found(1)).name);
                        return;
                    elseif any(strcmpi({variables.name},'x'))
                        found = find(strcmpi({variables.name},'x'));
                        variables(found(1)).name

                        loadStruct = load(theFile,variables(found(1)).name);
                        x = loadStruct.(variables(found(1)).name);
                        
                        y = [];
                        if any(strcmpi({variables.name},'y'))
                            found = find(strcmpi({variables.name},'y'));
                            variables(found(1)).name
                            
                            loadStruct = load(theFile,variables(found(1)).name);
                            y = loadStruct.(variables(found(1)).name);
                        end
                        ds = prtDataSetClass(x,y);
                            
                        return;
                    elseif any(strcmpi({variables.name},'data'))
                        found = find(strcmpi({variables.name},'data'));
                        variables(found(1)).name
                        
                        loadStruct = load(theFile,variables(found(1)).name);
                        x = loadStruct.(variables(found(1)).name);
                        
                        y = [];
                        if any(strcmpi({variables.name},'targets'))
                            found = find(strcmpi({variables.name},'targets'));
                            variables(found(1)).name
                            
                            loadStruct = load(theFile,variables(found(1)).name);
                            y = loadStruct.(variables(found(1)).name);
                        end
                        ds = prtDataSetClass(x,y);
                        
                        return;
                    end
            end
        end
        
        function ds = userChooseTargetVariable(self,ds)
            str = {'We can''t determine from text files which columns to use as';
                '"targets" or "labels".  You can choose one below,';
                'or choose "cancel" to leave the data unlabeled'};
            
            [selected,ok] = listdlg('ListString',ds.featureNames,'SelectionMode','single','PromptString',str,'ListSize',[300,160]);
            
            if ~ok
                return;
            else
                ds.Y = ds.X(:,selected);
                ds.X = ds.X(:,setdiff(1:ds.nFeatures,selected));
            end
            
        end
    end
end