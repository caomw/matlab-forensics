
load testNAoutputSCF_EM
QF = 50:5:100;


nc = 2;

    
fid = fopen('table_us_SCF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h-1
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC(r,c,nc) > AUC_s(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);
        
fid = fopen('table_us2_SCF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h-1
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_s(r,c,nc) > AUC(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_s(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_s(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);


load testNAoutputDCF_EM
QF = 50:5:100;

       
fid = fopen('table_us_DCF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h-1
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC(r,c,nc) > AUC_s(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);
        
fid = fopen('table_us2_DCF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h-1
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_s(r,c,nc) > AUC(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_s(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_s(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);

load testNAoutputFFF_EM
QF = 50:5:100;

       
fid = fopen('table_us_FFF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h-1
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC(r,c,nc) > AUC_s(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);
        
fid = fopen('table_us2_FFF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h-1
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_s(r,c,nc) > AUC(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_s(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_s(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);