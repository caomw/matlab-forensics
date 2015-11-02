D=dir('*_extended.mat');

for ii=1:length(D)
    %disp(strrep(D(ii).name,'_extended.mat',''));
    movefile(D(ii).name,strrep(D(ii).name,'_extended.mat',''));
end