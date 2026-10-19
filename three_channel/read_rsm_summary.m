function values = read_rsm_summary(summaryFile, rowNumber)
%READ_RSM_SUMMARY Read one numeric response row from an ECLIPSE RSM file.

fileID = fopen(summaryFile, 'r');
assert(fileID >= 0, 'read_rsm_summary:FileOpen', ...
    'Cannot open %s.', summaryFile);
cleanup = onCleanup(@() fclose(fileID));

line = '';
for row = 1:rowNumber
    line = fgetl(fileID);
    assert(ischar(line), 'read_rsm_summary:UnexpectedEnd', ...
        'The file ended before row %d.', rowNumber);
end
values = sscanf(line, '%f').';
assert(numel(values) >= 5, 'read_rsm_summary:InvalidRow', ...
    'The selected row does not contain the expected summary values.');
end
