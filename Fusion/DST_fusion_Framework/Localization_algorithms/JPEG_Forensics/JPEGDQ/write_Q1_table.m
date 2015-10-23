
% load testDQoutputSCF_EM
% QF = 50:5:100;
% Q1err_avg = mean(Q1err,3);
%         
% fid = fopen('table_Q1_SCF.txt', 'wt');
% 
% [h,w] = size(Q1err_avg);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %1.2f', Q1err_avg(r,c)); 
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);
%         
% load testDQoutputDCF_EM
% QF = 50:5:100;
% Q1err_avg = mean(Q1err,3);
%         
% fid = fopen('table_Q1_DCF.txt', 'wt');
% 
% [h,w] = size(Q1err_avg);
% 
% for r = 1:2:h
%     fprintf(fid, ' & %d', QF(r));
%     for c = 1:2:w
%         fprintf(fid, ' & %1.2f', Q1err_avg(r,c)); 
%     end
%     fprintf(fid, ' \\\\\\cline{2-8}\n');
% end
% 
% fclose(fid);

load testDQoutputFFF_EM
QF = 50:5:100;
Q1err_avg = mean(Q1err,3);
        
fid = fopen('table_Q1_FFF.txt', 'wt');

[h,w] = size(Q1err_avg);

for r = 1:2:h
    fprintf(fid, ' & %d', QF(r));
    for c = 1:2:w
        fprintf(fid, ' & %d', round(100*Q1err_avg(r,c))); 
    end
    fprintf(fid, ' \\\\\\cline{2-8}\n');
end

fclose(fid);