function [ Var ] = getCFAVar( block_struc )
        blockdata=double(block_struc.data);
        G=blockdata(:,:,1);
        G_CFA=boolean(blockdata(:,:,2));
        GOrig=G(G_CFA);
        GInterp=G(~G_CFA);
        Var(:,:,1)=var(GOrig);
        Var(:,:,2)=var(GInterp);
end