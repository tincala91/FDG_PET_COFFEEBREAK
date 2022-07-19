function img_rtf = img2rtf(file_name)
  % img = imread(file_name);
  fid = fopen(file_name,'rb');
  bytes = fread(fid);
  hex = dec2hex(bytes);
  %% out apparently not needed, the dec2hex returns char already
  %% Is it just transposition? 
  imagehex = hex';
  
  img_rtf = lower(imagehex);
