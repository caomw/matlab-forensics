for ii=1:101
    ii
    if Table_RW.Sp.Successes(ii,7)>0
        figure(1);
        imagesc(BinMasks{Table_RW.Sp.Successes(ii,1)}{Table_RW.Sp.Successes(ii,2)});
        figure(2);
        FullList=find(max(Table_RW.Sp.Results{Table_RW.Sp.Successes(ii,1)}{Table_RW.Sp.Successes(ii,2)},[],2)>0.45);
        disp(SpList{Table_RW.Sp.Successes(ii,1)})
        disp( [Table_RW.Sp.Successes(ii,1) Table_RW.Sp.Successes(ii,2) size(FullList)])
        
        load(SpFiles{Table_RW.Sp.Successes(ii,1)}{FullList(1)});
        for jj=1:length(Results.imin)
            imagesc(Results.dispImages{Results.imin(jj)})
            title(Results.imin(jj))
            pause;
        end
        
        disp('******************************************');
        
        load(SpFiles{Table_RW.Sp.Successes(ii,1)}{FullList(end)});
        for jj=1:length(Results.imin)
            imagesc(Results.dispImages{Results.imin(jj)})
            title(Results.imin(jj))
            pause;
        end
        
    end
end