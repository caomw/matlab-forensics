function[extBBA] = extendBBA(BBA, new_name, new_model)
    extBBA.K = BBA.K;
    extBBA.name = new_name;
    extBBA.model = new_model;
    
    assgn = fieldnames(BBA.assignments);
    masklen = length(assgn{1}(2:end));
    for i=1:numel(assgn)
        for w=1:length(BBA.model.EventList)
            %retrieve event name
             if strcmpiis(assgn{i}(2:masklen+1), BBA.model.EventList(w).EventMask)
                 name = BBA.model.EventList(w).EventName;
             end
        end
        for el=1:length(new_model.EventList)
            if strcmpiis(name(1:end-1),new_model.EventList(el).EventName(1:length(name(1:end-1))))
                extBBA.assignments.(['s' new_model.EventList(el).EventMask(1:masklen)]) = BBA.assignments.(assgn{i});
            end
        end
    end
end
