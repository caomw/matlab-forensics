function[Bel] = getBelief(BBA, setlist)
    
    Bel=sym(0);
    id = getSetId(BBA.model,setlist);
    for i=1:size(BBA.assignments,1)
        check1 = BBA.assignments{i,1};
        check1 = str2num([check1(:)]); %#ok<*ST2NM>
        check2 = str2num([id(:)]);
                
        if sum(check1>check2)==0 && sum(check1)>0 %trova sottoinsieme, scarta l'insieme nullo (è il conflitto)
            Bel = Bel + BBA.assignments{i,2};
        end
    end

end