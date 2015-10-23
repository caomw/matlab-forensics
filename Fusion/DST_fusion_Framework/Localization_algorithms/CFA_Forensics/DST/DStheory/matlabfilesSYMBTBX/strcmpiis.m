function[string] = strcmpiis(string1, string2)
    tmp1 = strrep(string1,' ','');
    tmp2 = strrep(string2,' ','');
    string = strcmpi(tmp1,tmp2);
end