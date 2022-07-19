function out_line = replace_in_line(in_line, struc_values, ...
                                 open_marker, close_marker)
  % Replaces placeholders enclosed by open_marker and close_marker
  % by corresponding values found in struc_values
  % if placeholder contains ':', the string preceding it 
  % is interpreted as formating string passed to sprintf
  % if formatting string is missing an %s is assumed
  % For ex. <<%03.5f:test_value>> with test value = 0.4
  % will be replaced by 000.40000
  %
  % In case of incorrect formatting, a warning will be raised,
  % and original placeholder will be used instead of value

  out_line = '';
  match_string = sprintf('(%s[%%a-zA-Z0-9:.]+%s)', ...
                         open_marker, close_marker);
  markers = regexp(in_line, match_string, 'tokenExtents');
  if isempty(markers)
    out_line = in_line;
    return;
  end
  
  start_pos = 1;
  for pos = markers 
    placeholder = pos{1};
    out_line = [out_line in_line(start_pos : placeholder(1) - 1)];
    try
      tag = in_line(placeholder(1) + size(open_marker, 2) : ...
                    placeholder(2) - size(close_marker, 2));
      sep_pos = regexp(tag, ':');
      if size(sep_pos, 2) == 0
        val = sprintf('%s', struc_values.(tag));
      elseif size(sep_pos, 2) == 1
        val = sprintf(tag(1:sep_pos(1) - 1), ...
                      struc_values.(tag(sep_pos(1) + 1: end)));
      else
        warning('Tag %s contains several separators', tag);
        val = tag;
      end
    catch ME
      warning('Unable to interpret tag %s for %s', tag, ME.message);
        val = tag;
    end
    out_line = [out_line val];
    start_pos = placeholder(2) + 1;
  end
  out_line = [out_line in_line(start_pos : end)];
end
