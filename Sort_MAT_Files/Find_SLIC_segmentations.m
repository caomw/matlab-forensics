MAT_Base='/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/';
MatFileList=dir([MAT_Base 'Unsorted/*.mat']);
disp('List done');

mkdir([MAT_Base 'SLIC']);

for ii=1:length(MatFileList)
    Loaded=load([MAT_Base 'Unsorted/' MatFileList(ii).name]);
    if isfield(Loaded,'l')
        movefile([MAT_Base 'Unsorted/' MatFileList(ii).name], [MAT_Base '/SLIC/' MatFileList(ii).name]);
        disp('Found one');
    end
    pause(0.2);
    if ~mod(ii,20)
        disp(ii)
    end
end