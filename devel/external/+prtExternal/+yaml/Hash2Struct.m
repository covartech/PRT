function Data = Hash2Struct(hashMap)
% This function converts object of type java.util.HashMap to matlab struct.
% Inputs:
%   - hashMap : java.util.HashMap object
% Outputs:
%   - Data    : matlab struct
% This code is based on template provided by Jan Siroky on
% http://stackoverflow.com/questions/1638018/is-there-already-a-yaml-library-parser-for-matlab


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
        ----  ---------   --------------------------------------------------
        jc    01-Mar-11   First implementation
        jc    03-Mar-11   Arrays of struct support
        jc    09-Mar-11   DateTime support extended
        jc    15-Mar-11   Support for different encodings
        jc    08-May-11   Support for yaml read of cell of structs
%}
%======================================================================

import prtExternal.yaml.*;

if isa(hashMap,'java.util.ArrayList')
    iterator = hashMap.iterator();
    index = 0;
    while (iterator.hasNext())
        index = index +1;
        %Data(index)= Hash2Struct(iterator.next());
        res   = Hash2Struct(iterator.next());
        if index==1
            Data = res;
        else
            if iscell(Data)
                Data{index} = res;
            elseif isequal(fieldnames(res),fieldnames(Data))
                Data(index) = res;
            else % convert array to cell
                Data = num2cell(Data);
                Data{index}= res;
            end            
        end        
    end
else
    Data = [];
    iterator = hashMap.keySet().iterator();
    while (iterator.hasNext())
        field = iterator.next();
        if ~isempty(field)
            d =  hashMap.get(java.lang.String(field));
            
            %Added 2011.08.25 by Peter Torrione to handle structs with
            %empty fields
            if isa(d,'java.util.ArrayList') && d.isEmpty
                Data.(field) = [];
                continue;
            end
            
            switch class(d)
                case {'java.util.LinkedHashMap'}
                    Data.(field) = Hash2Struct(d);
                case {'java.util.ArrayList'}
                    switch class(d.get(0))
                        case {'char' ,'double','java.util.Date'}
                            it = d.iterator();
                            val={};
                            while (it.hasNext())
                                val(end+1)={it.next()};
                            end
                            if all(cellfun(@(x) isnumeric(x),val))
                                val = cell2mat(val);
                            end
                        case {'java.util.ArrayList'}
                            itr = d.iterator();
                            val={};
                            r=1;
                            while (itr.hasNext())
                                row=itr.next();
                                itc = row.iterator();
                                c=1;
                                while(itc.hasNext())
                                    val{r,c}=itc.next();
                                    c=c+1;
                                end
                                r=r+1;
                            end
                            if all(cellfun(@(x) isnumeric(x),val))
                                val = cell2mat(val);
                            end
                        case {'java.util.LinkedHashMap'}
                            for hh=0:(d.size-1)
                                hm=d.get(hh);
                                h2sres = Hash2Struct(hm);
                                h2sres_fn = fieldnames(h2sres);
                                
                                if isfield(Data,field)
                                    if iscell(Data.(field))
                                        Data.(field){hh+1}= h2sres;
                                    elseif isequal(h2sres_fn,fieldnames(Data.(field)))
                                        Data.(field)(hh+1)= h2sres;
                                    else % convert array to cell
                                        Data.(field) = num2cell(Data.(field));
                                        Data.(field){hh+1}= h2sres;
                                    end
                                else
                                    Data.(field)= h2sres;
                                end
                            end
                            continue;
                            
                        otherwise
                            error('prt:yaml:Struct2Hashmap','Cannot read YAML file field %s is of an unknown Java data type.',field);
                    end
                    
                    
                    Data.(field) = val;
                otherwise
                    
                    Data.(field) = d;
            end
        end
    end
end