function replace_in_file(pth_template, pth_out, struc_values)
  % function reads input pth_template pfile line by line
  % and replaces parameters in markers << and >> by corresponding
  % values in struc_values field. Resulting string will be written
  % to pth_out.
  
  % this function calls function replace_in_line, that
  % replaces placeholders enclosed by open_marker and close_marker
  % by corresponding values found in struc_values
  % if placeholder contains ':', the string preceding it 
  % is interpreted as formating string passed to sprintf
  % if formatting string is missing an %s is assumed
  % For ex. <<%03.5f:test_value>> with test value = 0.4
  % will be replaced by 000.40000
  %
  % In case of incorrect formatting, a warning will be raised,
  % and original placeholder will be used instead of value  
  
  open_marker = '<<';
  close_marker = '>>';

  if ~isstruct(struc_values)
    error('struc_values must be a structure');
  end

  f_template = fopen(pth_template, 'r'); %this will open a file in markdown format
  
  if exist(pth_out, 'file')
    warning('Output file %s already exists. It will be overwritten.', ...
            pth_out);
  end

  f_out = fopen(pth_out, 'w'); %this will write a file in the same format as the original template? 

  in_line = fgets(f_template); 
  while ischar(in_line)    
    out_line = replace_in_line(in_line, struc_values, ... %I changed from replace_line to replace_in_line, correct? 
                               open_marker, close_marker);
                              
    fprintf(f_out, '%s', out_line);
    in_line = fgets(f_template);
  end

  fclose(f_template);
  fclose(f_out);
end
