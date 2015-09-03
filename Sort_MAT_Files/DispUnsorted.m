In_Base='/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/';
FolderIn='Unsorted';

%InList=dir([In_Base FolderIn '/*.mat']);

for ii=264240:length(InList)
    Loaded=load([In_Base FolderIn '/' InList(ii).name]);
    
    if (~isfield(Loaded,'Result'))  || numel(Loaded.Result)>10^6 || isstruct(Loaded.Result) %&& ~isfield(Loaded,'Results')
        if ~(isfield(Loaded,'Results') && isfield(Loaded.Results,'dispImages'))
            disp(Loaded)
            pause;
        end
    end
end