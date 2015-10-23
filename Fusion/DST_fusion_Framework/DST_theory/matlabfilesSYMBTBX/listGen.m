Ntool = 3;
N = 2^Ntool;
names = {'a','b','c'};

arr = N-1:-1:0;
bin = dec2bin(arr);

oFile = 'NewOutput.txt';
fid = fopen(oFile,'w+');
for i = 1:N
    string=[];
    for n = 1 : Ntool
        if strcmp(bin(i,n),'1')
            string = [string, 't',names{n},', '];
        else
            string = [string, 'n',names{n},', '];
        end
    end
    fprintf(fid,'%d (%s) \n',i,string);
end
fclose(fid);
display(['File generated: ',oFile]);