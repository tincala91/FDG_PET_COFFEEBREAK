function [work_files, coivox] = B_nii_setOriginCOM(vols)

%Sets position and orientation of input image(s) to match SPM's templates
%  SPM's normalize function uses the origin as a starting estimate
%  This script provides a robust estimate for the origin.
%  This is particularly important for CT, where initial origin is relative
%  to the table, not to the scanner isocenter, whereas SPM assumes the
%  origin is near the anterior commisure.
% vols : images to reorient, assumed to be from same individual and session.
%        origin estimated from first image and applied to others. For 4D
%        files (e.g. fMRI sessions) you only specify the file name, with
%        the estimate applied to all volumes
%Examples
%  nii_setOrigin('T1.nii');
%  nii_setOrigin(strvcat('T1.nii','fMRI.nii'),1); %estimated on T1, applied to both

  if ischar(vols)
    vols = cellstr(vols);
  end
  [path, basename, ext] = fileparts(vols{1});

  work_dir = fullfile(path, 'SPM', '.');
  if ~exist(work_dir, 'dir')
    mkdir(work_dir);
  else
    warning('SPM folder exist, it will be replaced');
    rmdir(work_dir, 's');
    mkdir(work_dir);
  end

  work_files = {size(vols)};
  for iFile = 1:size(vols, 1)
    copyfile(vols{iFile}, work_dir);
    [~, basename, ext] = fileparts(vols{iFile});
    work_files{iFile} = fullfile(work_dir, [basename, ext]);
  end

  spm_jobman('initcfg');
  coivox = ones(4,1);

  [~, nam, ~] = fileparts(work_files{1});
  hdr = spm_vol([work_files{1}, ',1']); %load header 
  img = spm_read_vols(hdr); %load image data
  img = img - min(img(:));
  img(isnan(img)) = 0;

  %find center of mass in each dimension (total mass divided by weighted location of mass
  sumTotal = sum(img(:));
  coivox(1) = sum(sum(sum(img,3),2)'.*(1:size(img,1)))/sumTotal; %dimension 1
  coivox(2) = sum(sum(sum(img,3),1).*(1:size(img,2)))/sumTotal; %dimension 2
  coivox(3) = sum(squeeze(sum(sum(img,2),1))'.*(1:size(img,3)))/sumTotal; %dimension 3
  XYZ_mm = hdr.mat * coivox; %convert from voxels to millimeters
  fprintf(['%s center of brightness differs from current origin '...
           'by %.0fx%.0fx%.0fmm in X Y Z dimensions\n'], ...
          nam, XYZ_mm(1), XYZ_mm(2), XYZ_mm(3)); 

  for v = 1:size(work_files,1) 
    fname = work_files{v};
    [pth, nam, ext] = fileparts(fname);
    hdr = spm_vol([fname ',1']); %load header of first volume 
    mat_name = fullfile(pth, [nam '.mat']);
    if exist(mat_name,'file')
        destname = fullfile(pth,[nam '_old.mat']);
        copyfile(mat_name, destname);
        fprintf('Backuping old .mat file of %s\n', nam);
    end

    hdr.mat(1,4) =  hdr.mat(1,4) - XYZ_mm(1);
    hdr.mat(2,4) =  hdr.mat(2,4) - XYZ_mm(2);
    hdr.mat(3,4) =  hdr.mat(3,4) - XYZ_mm(3);
    spm_create_vol(hdr);
    if exist(mat_name, 'file')
        delete(mat_name);
    end
  end
end
