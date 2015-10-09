Defectives={'aa3b4f7caf9de8c1d6551c33045fb4c1','b0060704d02f1229b75cbd550c7267b4','bc04da26ab41ce92565dd3c686dae6c8','cc263a4c9ff9943acbb9049f637a0bed','d4aff0ad5f4f99fc6cad4243b926eda7','d9b9f5db7d29a3855cceef574145b595','ca472f184807aded538221ac0b5ac27b','bb7ed6b43f565a1fe2ebcbf99886d1d4'};

Paths={'/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/1st Image Forensics Challenge/dataset-dist/phase-01/training/fake','/media/marzampoglou/3TB/markzampoglou/ImageForensics/Datasets/Resaved/','/media/marzampoglou/New_NTFS_Volume/markzampoglou/ImageForensics/AlgorithmOutput/'};

for Pa=1:length(Paths)
for Def=1:length(Defectives)
    
        Files=getAllFiles(Paths{Pa},[Defectives{Def} '.*'],true);
        for F=1:length(Files)
            delete(Files{F});
        end
        
    
end
end