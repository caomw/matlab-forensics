function[fused] = OrthogonalSum(BBA1, BBA2)
    BBAF = struct('assignments',{},'frame',{});
    BBAF(1).assignments=[];
    ass1 = fieldnames(BBA1.assignments);
    ass2 = fieldnames(BBA2.assignments);    
    
    emptyset = ['s' repmat('0',1,length(ass1{1})-1)];
    for a1=1:numel(ass1)
        for a2=1:numel(ass2)
            tmp = ['s' intersect(ass1{a1}(2:end),ass2{a2}(2:end))];
            if isfield(BBAF.assignments,tmp)
                BBAF.assignments.(tmp) = BBAF.assignments.(tmp) + BBA1.assignments.(ass1{a1}) * BBA2.assignments.(ass2{a2});
            else
                BBAF.assignments.(tmp) = BBA1.assignments.(ass1{a1}) * BBA2.assignments.(ass2{a2});
            end
        end
    end
    
    assF=fieldnames(BBAF.assignments);
    for k=1:numel(assF)
        if ~strcmpi(assF{k},emptyset)
            BBAF.assignments.(assF{k}) = BBAF.assignments.(assF{k})/(1-BBAF.assignments.(emptyset));
        end
    end
    fused=BBAF;
end

