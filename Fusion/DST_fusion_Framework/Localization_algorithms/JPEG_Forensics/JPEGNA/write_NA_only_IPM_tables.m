
load pdz_only_IPM_1024

QF = {'50-57', '58-67', '68-76', '77-85', '86-95'};
    
fid = fopen('table_pdz_only_IPM_1024.txt', 'wt');

[h,w] = size(pd2);

for r = 1:h
    fprintf(fid, ' & %s', QF{r});
    for c = 1:w
            fprintf(fid, ' & %2.1f', 100*pd2(r,c));
    end
    fprintf(fid, ' \\\\\\hline\n');
end

fclose(fid);


load acc_only_IPM_1024

QF = {'50-57', '58-67', '68-76', '77-85', '86-95'};
    
fid = fopen('table_acc_only_IPM_1024.txt', 'wt');

[h,w] = size(pd2);

for r = 1:h
    fprintf(fid, ' & %s', QF{r});
    for c = 1:w
            fprintf(fid, ' & %2.1f', 100*acc2(r,c));
    end
    fprintf(fid, ' \\\\\\hline\n');
end

fclose(fid);
        