% 
% load testNAoutputSCF_EM
% QF = 50:5:100;
% Q1err_avg = mean(Q1err,3);
%         
% fid = fopen('table_kk_SCF.txt', 'wt');
% 
% [h,w] = size(kkerr);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %d', round(100*kkerr(r,c))); 
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);
% 
% fid = fopen('table_Q1_SCF.txt', 'wt');
% 
% [h,w] = size(Q1err_avg);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %d', round(100*Q1err_avg(r,c))); 
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);
%         
load testNAoutputDCF_EM
QF = 50:5:100;
Q1err_avg = mean(Q1err,3);
% 
% fid = fopen('table_kk_DCF.txt', 'wt');
% 
% [h,w] = size(kkerr);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %d', round(100*kkerr(r,c))); 
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);
%         
% fid = fopen('table_Q1_DCF.txt', 'wt');
% 
% [h,w] = size(Q1err_avg);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %d', round(100*Q1err_avg(r,c)));  
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);
% 
fid = fopen('table_kk_Q1_DCF.txt', 'wt');

[h,w] = size(Q1err_avg);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        fprintf(fid, ' & %d(%d)', round(100*kkerr(r,c)), round(100*Q1err_avg(r,c)));
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);

load testNAoutputFFF_EM
QF = 50:5:100;
Q1err_avg = mean(Q1err,3);

% fid = fopen('table_kk_FFF.txt', 'wt');
% 
% [h,w] = size(kkerr);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %d', round(100*kkerr(r,c))); 
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);
%         
% fid = fopen('table_Q1_FFF.txt', 'wt');
% 
% [h,w] = size(Q1err_avg);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %d', round(100*Q1err_avg(r,c)));
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);


fid = fopen('table_kk_Q1_FFF.txt', 'wt');

[h,w] = size(Q1err_avg);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        fprintf(fid, ' & %d(%d)', round(100*kkerr(r,c)), round(100*Q1err_avg(r,c)));
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);