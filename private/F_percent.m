function F_percent(data, mask, rois, template_table, start_row, start_col)
  % data: cellarray of spmT files corresponding to each condition
  % mask: brain mask used to calculate total number of voxels
  % rois: cellaray of label images with roi definitions
  % template_table: path to xls table used as template to egnerate the statistics

  data = cellstr(data);
  rois = char(rois);
  voxels = struct([]);
  
  [data_path, ~, ~] = fileparts(mask);

  [total_voxels, regions] = rex(mask, rois,...
                                'summary_measure', 'count',...
                                'level', 'clusters',...
                                'output_type', 'none',...
                                'gui', 0,...
                                'select_clusters', 0);
  total_voxels = total_voxels';                              

  for iData = 1:size(data, 1)
    [~, data_name, ~] = fileparts(data{iData, 1});
    pos = find(data_name == '_');
    pos = pos(1);
    
    voxels(end+1).name = data_name;
    voxels(end).short_name = data_name(pos+1:end);
    voxels(end).vox = rex(data{iData, 1}, rois,...
                           'summary_measure', 'count',...
                           'level', 'clusters',...
                           'output_type', 'none',...
                           'gui', 0,...
                           'select_clusters', 0)';
  end
  
  counts = [voxels(:).vox total_voxels];
  
  [~, basename, ext] = fileparts(template_table);
  res_table = fullfile(data_path, [basename, ext]);
  copyfile(template_table, res_table);

  try
    range = sprintf('%s%d:%s%d', start_col, start_row, ...
                    start_col + size(Counts, 2) - 1, ...
                    start_row + size(Counts, 1) - 1)
    writematrix(counts, res_table, 'Range', range);
  catch
    warning('Failed to write excel file, trying tsv');
    res_table = fullfile(data_path, [basename, '.tsv']);
    f = fopen(res_table, 'w');

    fprintf(f, '%s\t%s', 'ROI_number', 'ROI');
    tmp = repmat('\ttot_voxels_%s', 1, size(voxels, 1));
    fprintf(f, tmp, voxels(:).short_name);
    fprintf(f, '\t%s', 'Tot_voxels_ROI');
    tmp = repmat('\tperc_voxels_%s', 1, size(voxels, 1));
    fprintf(f, tmp, voxels(:).short_name);
    fprintf(f, '\n');

    for i = 1:size(counts, 1)
      roi = regions{i};
      fprintf(f, '%d\t%s', i, roi);
      tmp = repmat('\t%d', 1, size(voxels, 1));
      fprintf(f, tmp, counts(i, 1:end-1));
      fprintf(f, '\t%d', counts(i, end));
      tmp = repmat('\t%.2f', 1, size(voxels, 1));
      fprintf(f, tmp, 100 * counts(i, 1:end-1) ./ counts(i, end));
    fprintf(f, '\n');
    end
    fclose(f);
  end
end
