function[model] = modelParser(filename)
    
%parse file
fid = fopen(filename);
if fid<0
    display(['Cannot open model file ', filename]);
end

k=1;
while 1
    tline{k} = fgetl(fid);
    if ~ischar(tline{k})
        break
    end
    k=k+1;
end
fLen = k;
%INTERPRETATION...

%first line must contain the number of elementary events
ptr=1;
while ~strcmpiis(tline{ptr},'Nelev=') && ptr<fLen
    ptr=ptr+1;
end
model.Nelev = str2num(tline{ptr+1});
ptr = ptr+2;

emptymask = [repmat('0',1,model.Nelev)];
%After, a list of elementary events follows

expr = '<(\w+).*?>.*?</\1>';
in=1;ic=1;
while ptr<fLen
    line = stripsp(tline{ptr});
    if ~isempty(strfind(line,'<EventList>'))
        tmpptr=0;
        mass = [];
        setlist=cell(1,1);
        while isempty(strfind(tline{ptr},'</EventList>'))
           ptr=ptr+1; 
           tmpptr=tmpptr+1;
        end
        tagline = [tline{ptr-tmpptr+1:ptr-1}];
        [tok mat] = regexp(tagline, expr, 'tokens', 'match');
        %now parse tokens
        s=1;
        for j=1:length(mat)
            parsed = mat{j}(length(tok{1,j}{1,1})+3:end-(length(tok{1,j}{1,1})+3));
            if strcmpi(tok{1,j}{1,1},'name')
                %store mass assignment
                model.EventList(in).EventName = parsed;
                in=in+1;
            elseif strcmpi(tok{1,j}{1,1},'id')
                %add to set list
                model.EventList(ic).EventId = str2double(parsed);
                tmp = emptymask;
                tmp(model.EventList(ic).EventId)='1';
                model.EventList(ic).EventMask = tmp;
                ic=ic+1;
            end
        end
        %update the actual BBA struct       
        a=0;
        ptr=ptr-1;        
    end
    ptr=ptr+1;
end
if ~isfield(model,'EventList')
    warning('modelParser: EVENT LIST IS EMPTY!');
end

end
%emptyset = ['s' repmat('0',1,length(ass1{1})-1)];
