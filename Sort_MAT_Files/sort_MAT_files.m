%MAT_Base='/media/marzampoglou/3TB/Recovery/Recuva/Excellent/Folders/folder_mat/';
%MatFileList=dir([MAT_Base '*.mat']);


mkdir([MAT_Base '01/Tw']);
mkdir([MAT_Base '01/TwRes']);
mkdir([MAT_Base '02/Tw']);
mkdir([MAT_Base '02/TwRes']);
mkdir([MAT_Base '04/Tw']);
mkdir([MAT_Base '04/TwRes']);
mkdir([MAT_Base '05/Tw']);
mkdir([MAT_Base '05/TwRes']);
mkdir([MAT_Base '07/Tw']);
mkdir([MAT_Base '07/TwRes']);
mkdir([MAT_Base '08/Tw']);
mkdir([MAT_Base '08/TwRes']);
mkdir([MAT_Base '09/Tw']);
mkdir([MAT_Base '09/TwRes']);
mkdir([MAT_Base '10/Tw']);
mkdir([MAT_Base '10/TwRes']);
mkdir([MAT_Base '12/Tw']);
mkdir([MAT_Base '12/TwRes']);
mkdir([MAT_Base '14/Tw']);
mkdir([MAT_Base '14/TwRes']);
mkdir([MAT_Base '16/Tw']);
mkdir([MAT_Base '16/TwRes']);

mkdir([MAT_Base 'IP_DIP/TwRes']);
mkdir([MAT_Base 'IP_DIP/Tw']);

mkdir([MAT_Base 'Unsorted/Tw']);
mkdir([MAT_Base 'Unsorted/TwRes']);

mkdir([MAT_Base 'Irrelevant']);
mkdir([MAT_Base 'Corrupt']);

mkdir([MAT_Base 'ThisOtherCell/Tw']);
mkdir([MAT_Base 'ThisOtherCell/TwRes']);


for ii=1:length(MatFileList)
    try
        disp(MatFileList(ii).name)
        Loaded=load([MAT_Base MatFileList(ii).name]);
        disp('Loaded');
        if isfield(Loaded,'Results')
            if strfind(Loaded.Name,'TwRes')
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/08/TwRes/' MatFileList(ii).name]);
            elseif strfind(Loaded.Name,'Tw')
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/08/Tw/' MatFileList(ii).name]);
            else
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/08/' MatFileList(ii).name]);
            end
               disp('08')
        elseif isfield(Loaded,'bayer')
            if strfind(Loaded.Name,'TwRes')
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/04/TwRes/' MatFileList(ii).name]);
            elseif strfind(Loaded.Name,'Tw')
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/04/Tw/' MatFileList(ii).name]);
            else
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/04/' MatFileList(ii).name]);
            end
                disp('04')
        elseif isfield(Loaded,'Result')
            if iscell(Loaded.Result)
                if length(Loaded.Result)==5
                    if strfind(Loaded.Name,'TwRes')
                        system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/05/TwRes/' MatFileList(ii).name]);
                    elseif strfind(Loaded.Name,'Tw')
                        system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/05/Tw/' MatFileList(ii).name]);
                    else
                        system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/05/' MatFileList(ii).name]);
                    end
                    disp('05')
                else
                    if strfind(Loaded.Name,'TwRes')
                        system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/ThisOtherCell/TwRes/' MatFileList(ii).name]);
                    elseif strfind(Loaded.Name,'Tw')
                        system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/ThisOtherCell/Tw/' MatFileList(ii).name]);
                    else
                        system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/ThisOtherCell/' MatFileList(ii).name]);
                    end
                    disp('ThisOtherCell')                    
                end
                   
            elseif isfield(Loaded.Result,'OutlierPrmsMap')
                if strfind(Loaded.Name,'TwRes')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/09/TwRes/' MatFileList(ii).name]);
                elseif strfind(Loaded.Name,'Tw')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/09/Tw/' MatFileList(ii).name]);
                else
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/09/' MatFileList(ii).name]);
                end
                   disp('09')
            elseif isfield(Loaded.Result,'DIPM')
                if strfind(Loaded.Name,'TwRes')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/IP_DIP/TwRes/' MatFileList(ii).name]);
                elseif strfind(Loaded.Name,'Tw')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/IP_DIP/Tw/' MatFileList(ii).name]);
                else
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/IP_DIP/' MatFileList(ii).name]);
                end
            elseif isfield(Loaded.Result,'estVDCT')
                if strfind(Loaded.Name,'TwRes')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/12/TwRes/' MatFileList(ii).name]);
                elseif strfind(Loaded.Name,'Tw')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/12/Tw/' MatFileList(ii).name]);
                else
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/12/' MatFileList(ii).name]);
                end
                    disp('12')
            elseif sum(sum(Loaded.Result-round(Loaded.Result)))==0
                if strfind(Loaded.Name,'TwRes')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/10/TwRes/' MatFileList(ii).name]);
                elseif strfind(Loaded.Name,'Tw')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/10/Tw/' MatFileList(ii).name]);
                else
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/10/' MatFileList(ii).name]);
                end
                               disp('10')
            elseif min(min(Loaded.Result))<0
                if strfind(Loaded.Name,'TwRes')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/14/TwRes/' MatFileList(ii).name]);
                elseif strfind(Loaded.Name,'Tw')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/14/Tw/' MatFileList(ii).name]);
                else
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/14/' MatFileList(ii).name]);
                end
                    disp('14')
            elseif max(max(Loaded.Result))>1
                if strfind(Loaded.Name,'TwRes')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/07/TwRes/' MatFileList(ii).name]);
                elseif strfind(Loaded.Name,'Tw')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/07/Tw/' MatFileList(ii).name]);
                else
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/07/' MatFileList(ii).name]);
                end
                      disp('07')
            else
                if strfind(Loaded.Name,'TwRes')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Unsorted/TwRes/' MatFileList(ii).name]);
                elseif strfind(Loaded.Name,'Tw')
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Unsorted/Tw/' MatFileList(ii).name]);
                else
                    system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Unsorted/' MatFileList(ii).name]);
                end
                   disp('Unsorted');
            end
        elseif isfield(Loaded,'Name')
            if strfind(Loaded.Name,'TwRes')
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Unsorted/TwRes/' MatFileList(ii).name]);
            elseif strfind(Loaded.Name,'Tw')
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Unsorted/Tw/' MatFileList(ii).name]);
            else
                system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Unsorted/' MatFileList(ii).name]);
            end
               disp('Unsorted');
        else
            system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Irrelevant/' MatFileList(ii).name]);
                disp('Irrelevant');
        end
    clear Loaded
    disp('Cleared');
    catch ME
        if ~strcmp(ME.identifier,'MATLAB:load:couldNotReadFile') && ~strcmp(ME.identifier,'MATLAB:load:notBinaryFile') && ~strcmp(ME.identifier,'MATLAB:load:cantReadFile') && ~strcmp(ME.identifier,'MATLAB:load:unableToReadMatFile')
            disp(ME.message);
        else
            system(['mv ' MAT_Base MatFileList(ii).name ' ' MAT_Base '/Corrupt/' MatFileList(ii).name]);
            disp('Corrupt');
        end
        pause(0.5);
    end
    if ~mod(ii,2000)
        disp(ii)
    end
    pause(0.1);
end