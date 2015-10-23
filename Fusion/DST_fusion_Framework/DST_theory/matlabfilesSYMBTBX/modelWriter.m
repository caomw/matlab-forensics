function[] = modelWriter(model, outputFile)

fid = fopen(outputFile, 'w+');

fprintf(fid,'Nelev =\n');
fprintf(fid,'\t%.0f\n\n', model.Nelev);

fprintf(fid,'<EventList>\n');
for i=1:length(model.EventList)
   fprintf(fid,'\t<name>%s</name>\t<id>%.0f</id>\n',model.EventList(i).EventName, model.EventList(i).EventId);
end
fprintf(fid,'</EventList>\n');
fclose(fid);
end