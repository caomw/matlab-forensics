rng(1936);

M=0;
V=0.00;

%SmallCFAList={[2 1;3 2] [2 3;1 2] [3 2;2 1] [1 2;2 3]};

SmallCFAList={[1 2;2 3] [2 1;2 3] [3 2;1 2]};
LargeCFAList={ [1 2;2 3] [3 2;2 1] [2 1;3 2]  [2 3;1 2] [1 2; 3 1] [1 3;2 1] [2 1;1 3] [3 1;1 2] [3 1;2 3] [3 2;1 3] [1  3;3 2] [2 3;3 1]                  [1 2;1 3] [1 3;1 2] [1 1;2 3] [1 1;3 2] [2 1;3 1] [3 1;2 1] [2 3;1 1] [3 2;1 1] [3 1;3 2] [3 2;3 1] [3 3;1 2] [3 3;2 1] [1 3;2 3] [2 3;1 3] [1 2;3 3] [2 1;3 3]                                                   [2 1;2 3] [2 3;2 1] [2 2;1 3] [2 2;3 1]  [1 2;3 2] [3 2;1 2] [1 3;2 2] [3 1;2 2]};


CFAList=LargeCFAList;
FolderBase=['./Samples/LargeList/'];



for TrueArray=1:length(CFAList)
    for ii=1:6
        for jj=3:19
            filename=[num2str(TrueArray) '_' num2str(ii) '_' num2str(jj) '.png' ];
            im=imread([FolderBase filename]);
            im=imnoise(im,'gaussian',M,V);
                        
            for TestArray=1:length(CFAList)
                
            end
        end
    end
end
