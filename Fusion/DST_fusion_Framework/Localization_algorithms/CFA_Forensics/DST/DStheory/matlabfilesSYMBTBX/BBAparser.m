function[BBA] = BBAparser(filename)

%parse file
fid = fopen(filename);
[path,file] = fileparts(filename);
k=1;
while 1
    tline{k} = fgetl(fid); %#ok<AGROW>
    if ~ischar(tline{k})
        break
    end
    k=k+1;
end
fLen = k;

%INTERPRETATION...

%First line must contain the name
ptr=1;
try
    while ~strcmpiis(tline{ptr},'Name=') && ptr<fLen
        ptr=ptr+1;
    end
    BBA.name = strtrim(tline{ptr+1});
    ptr = ptr+2;
catch
    error(['Cannot find mandatory field "Name" in BBA file ',filename]);
end

%Then, the model file must follow.
try
    while ~strcmpiis(tline{ptr},'ModelFile=') && ptr<fLen
        ptr=ptr+1;
    end
    fname = strtrim(tline{ptr+1});
    try
        BBA.model = modelParser(fname);
    catch
        fname = fullfile(path,fname);
        BBA.model = modelParser(fname);
    end
    [pathstr, name, ext]  = fileparts(fname);
    BBA.modelFile = [name,ext];
    ptr = ptr+2;
catch ME
    error(['Cannot find mandatory field "ModelFile" in BBA file ',filename]);
end

%After, the conflict is specified
try
while ~strcmpiis(tline{ptr},'K=') && ptr<fLen
    ptr=ptr+1;
end
BBA.K = sym(strtrim(tline{ptr+1}));
ptr = ptr+2;
catch
    error(['Cannot find mandatory field "K" in BBA file ',filename,'  Recall that if no coflict is present, then you should set K to 0']);
end


%After, the list of basic belief assignments must follow
while ~strcmpiis(tline{ptr},'BBA={') && ptr<fLen
    ptr=ptr+1;
end

expr = '<(\w+).*?>.*?</\1>';
z=1;
while ~strcmpiis(tline{ptr},'}')
    line = strtrim(tline{ptr});
    if ~isempty(strfind(line,'<assignment>'))
        tmpptr=0;
        mass = [];
        setlist=cell(1,1);
        while isempty(strfind(tline{ptr},'</assignment>'))
           ptr=ptr+1; 
           tmpptr=tmpptr+1;
        end
        tagline = [tline{ptr-tmpptr+1:ptr-1}];
        [tok mat] = regexp(tagline, expr, 'tokens', 'match');
        %now parse tokens
        s=1;
        for j=1:length(mat)
            parsed = mat{j}(length(tok{1,j}{1,1})+3:end-(length(tok{1,j}{1,1})+3));
            if strcmpi(tok{1,j}{1,1},'mass')
                %store mass assignment
                    mass = sym(strrep(parsed,'.',''));
            elseif strcmpi(tok{1,j}{1,1},'set')
                %add to set list
                setlist{s}=parsed;
                s=s+1;
            end
        end
        %update the actual BBA struct
        setId = getSetId(BBA.model, setlist); %ricava id insieme
        BBA.assignments{z,1} = setId;
        BBA.assignments{z,2} = mass;        
        z=z+1;
        ptr=ptr-1;
        
    end
    ptr=ptr+1;
end



end
%emptyset = ['s' repmat('0',1,length(ass1{1})-1)];

function[string] = strcmpiis(string1, string2)
    tmp1 = strrep(string1,' ','');
    tmp2 = strrep(string2,' ','');
    string = strcmpi(strtrim(tmp1),strtrim(tmp2));
end
