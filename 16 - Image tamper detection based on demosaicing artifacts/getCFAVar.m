function [ Var ] = getCFAVar( block_struc )
        blockdata=double(block_struc.data);
        blockdata(:,:,1)
        blockdata(:,:,2)
        G=blockdata(:,:,1);
        GOrig=G(blockdata(:,:,2));
        GInterp=G(~blockdata(:,:,2));
        Var(:,:,1)=var(GOrig);
        Var(:,:,2)=var(GInterp);
end