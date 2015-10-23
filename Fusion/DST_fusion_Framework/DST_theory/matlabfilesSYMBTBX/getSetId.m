function[setId]=getSetId(model, setlist)

emptymask=repmat('0',1,(model.Nelev));
setId = emptymask;
for i=1:length(setlist)
    found=0;
    for k=1:length(model.EventList)
        if strcmpiis(setlist{i},model.EventList(k).EventName)
            setId(model.EventList(k).EventId)='1';
            found=1;
        end
    end
    if found==0
        warning(sprintf('getSetId: the event %s cannot be found',setlist{i}));
    end    
end
if strcmp(setId,emptymask)
    error('getSetId: cannot find ID for this setlist');
end

end