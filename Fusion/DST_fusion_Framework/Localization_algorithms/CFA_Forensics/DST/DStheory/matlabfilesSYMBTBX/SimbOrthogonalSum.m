function[BBAF] = SimbOrthogonalSum(BBA1, BBA2)
    BBAF = struct('assignments',{});
    BBAF(1).assignments=cell(1,2);
    ass1 = BBA1.assignments;
    ass2 = BBA2.assignments;    
    
    emptyset = [repmat('0',1,length(ass1{1,1}))];
    for a1=1:size(ass1,1)
        for a2=1:size(ass2,1)
            tmp = intersect(ass1{a1,1},ass2{a2,1});
            %matching = lookup(BBAF.assignments,tmp);
            matching = find(cellfun(@(x) strcmpi(tmp,x), BBAF.assignments(:,1)));
            if ~isempty(matching)
                BBAF.assignments{matching,2} = BBAF.assignments{matching,2} + ( BBA1.assignments{a1,2} * BBA2.assignments{a2,2} );
            else
                BBAF.assignments{end+1,1} = tmp;
                BBAF.assignments{end,2} = BBA1.assignments{a1,2} * BBA2.assignments{a2,2};
            end
        end
    end
    
    %Remove the first row, which is empty..
    BBAF.assignments(1,:) = [];
    
    %Normalize conflict
    %empty = lookup(BBAF.assignments,emptyset);
    empty = find(cellfun(@(x) strcmpi(emptyset,x), BBAF.assignments(:,1)));
    if ~isempty(empty)
        BBAF.K = BBAF.assignments{empty,2}; %by now, conflict is given by the sum of product of masses of set that gave empty intersection :-)
    else
        BBAF.K = sym(0);
    end
    
    for k=1:size(BBAF.assignments,1)
        if ~strcmpi(BBAF.assignments{k,1},emptyset)
                %BBAF.assignments{k,2} = simplify(BBAF.assignments{k,2} / (sym(1) - BBAF.K));
                BBAF.assignments{k,2} = BBAF.assignments{k,2} / (sym(1) - BBAF.K);
        end
    end
    BBAF.name = [BBA1.name,' ++ ',BBA2.name];
    BBAF.model = BBA1.model; %model had to be the same for the two to-be-fused BBAs..
    BBAF.modelFile = BBA1.modelFile; %model had to be the same for the two to-be-fused BBAs..
    if ~isempty(empty) %remove assignment to the empty set (it has been saved in conflict, because that is its meaning!)            
        BBAF.assignments(empty,:) = [];
    end
end



%%assegnamenti di prova...
% %Prova numerica
% BBA1=struct('assignments',{},'Frame',{});
% BBA1(1).assignments.('a010') = 0.4;
% BBA1.assignments.('a011')=0.3;
% BBA1.assignments.('a001')=0.3;
% BBA2.assignments.('a001')=0.2;
% BBA2.assignments.('a110')=0.8;
% [fused] = OrthogonalSum(BBA1, BBA2)
% %Prova simbolica
% AT=0.4;AN=0.3;ATN=0.3;BT=0.2;BN=0.8;
% BBA1(1).assignments.('a010') = 'AT';
% BBA1.assignments.('a011')='AN';
% BBA1.assignments.('a001')='ATN';
% BBA2.assignments.('a001')='BT';
% BBA2.assignments.('a110')='BN';
% [fused] = SimbOrthogonalSum(BBA1, BBA2);