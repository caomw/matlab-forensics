clc
clear
load '/users/fontani/Dropbox/Universita/FORENSIC/SPATIAL FUSION/utils/tables'

%spatial_svms.AJPEG = SVMtrainer_refinement(ajpeg_tables);
%save('spatial_svms.mat','spatial_svms');

%spatial_svms.NAJPEG = SVMtrainer_refinement(najpeg_tables);
%save('spatial_svms.mat','spatial_svms');

spatial_svms.CFA = SVMtrainer_refinement(cfa_tables);
save('spatial_svms.mat','spatial_svms');


