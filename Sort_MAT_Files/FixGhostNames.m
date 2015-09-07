%tmp=getAllFiles('~/ImageForensicsFeatures/Ghosts_PostCrash/75_0','*.mat',true);
%tmp=[tmp;getAllFiles('~/ImageForensicsFeatures/Ghosts_PostCrash/75_1','*.mat',true)];

for ii=12103:length(tmp)
    L=load(tmp{ii});
    L.Name=strrep(L.Name,'_Tw.j','.j');
    pause(0.1);
    save(tmp{ii},'-struct','L');
    pause(0.1);
end