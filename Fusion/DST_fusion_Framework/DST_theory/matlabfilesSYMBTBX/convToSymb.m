function[symexpr, vars] = convToSymb(string)
%Take a string and convert it in a symbolic expression

s = sym(string);
res = s.findsym;
%Obtain candidate variable list
vars = regexp(res, ',', 'split');

%declare symbolic variables
for i=1:numel(vars)
   syms(vars{i});
end

%Turn parsed assignment string into a symbolic expression
symexpr = eval(string);

end