function markp=Mark(bag)

[height,width]=size(bag);
pro=zeros(height,width);

for i=1:8:height
    if (i+7>height)
        i1=height;
    else
        i1=i+7;
    end
    for j=1:8:width
        if (j+7>width)
            j1=width;
        else
            j1=j+7;
        end
        a=bag(i:i1,j:j1);
        b=sum(a);
        if (j1-j<2)
            row=0;
        else
            row=max(b(2:j1-j))-min([b(1) b(j1-j+1)]);
        end
        b=sum(a');
        if (i1-i<2)
            col=0;
        else
            col=max(b(2:i1-i))-min([b(1) b(i1-i+1)]);
        end
        pro(i:i1,j:j1)=row+col;
    end
end

markp=pro;
toc