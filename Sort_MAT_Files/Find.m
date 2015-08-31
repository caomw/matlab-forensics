tmpList=dir('/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/SortedOut/04/Tw');

for ii=3:length(tmpList)
    LD=load(['/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/SortedOut/04/Tw/' tmpList(ii).name]);
    if strfind(LD.Name,'canonxt_kodakdcs330_sub_22')
        disp(tmpList(ii).name)
        tmpList(ii).date
        pause
    end
end