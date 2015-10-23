
load testDQoutputSCF_EM
QF = 50:5:100;

fid = fopen('table_china_SCF.txt', 'wt');

[h,w,NC] = size(AUC_c);

nc = 3;

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_c(r,c,nc) > AUC(r,c,nc) && AUC_c(r,c,nc) > AUC_s(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_c(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_c(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);
        
fid = fopen('table_us_SCF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC(r,c,nc) > AUC_c(r,c,nc) && AUC(r,c,nc) > AUC_s(r,c,nc)
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

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_s(r,c,nc) > AUC_c(r,c,nc) && AUC_s(r,c,nc) > AUC(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_s(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_s(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);


load testDQoutputDCF_EM
QF = 50:5:100;

fid = fopen('table_china_DCF.txt', 'wt');

[h,w,c] = size(AUC_c);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_c(r,c,nc) > AUC(r,c,nc) && AUC_c(r,c,nc) > AUC_s(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_c(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_c(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);
        
fid = fopen('table_us_DCF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC(r,c,nc) > AUC_c(r,c,nc) && AUC(r,c,nc) > AUC_s(r,c,nc)
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

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_s(r,c,nc) > AUC_c(r,c,nc) && AUC_s(r,c,nc) > AUC(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_s(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_s(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);

load testDQoutputFFF_EM
QF = 50:5:100;

fid = fopen('table_china_FFF.txt', 'wt');

[h,w,c] = size(AUC_c);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_c(r,c,nc) > AUC(r,c,nc) && AUC_c(r,c,nc) > AUC_s(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_c(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_c(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);
        
fid = fopen('table_us_FFF.txt', 'wt');

[h,w,c] = size(AUC);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC(r,c,nc) > AUC_c(r,c,nc) && AUC(r,c,nc) > AUC_s(r,c,nc)
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

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        if AUC_s(r,c,nc) > AUC_c(r,c,nc) && AUC_s(r,c,nc) > AUC(r,c,nc)
            fprintf(fid, ' & \\textbf{%1.3f}', AUC_s(r,c,nc));       
        else
            fprintf(fid, ' & %1.3f', AUC_s(r,c,nc));
        end
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);