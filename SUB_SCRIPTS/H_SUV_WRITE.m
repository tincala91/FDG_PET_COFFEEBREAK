function H_SUV_WRITE()

%declaring useful variables
global baseDir
global subj_code
global SPM8_Bqperml_SUV
dir_dicom=pwd;

renamedCOUNTfile=strcat(dir_dicom,'/','counts_',subj_code,'.nii');

% List of open inputs
% Image Calculator: Input Images - cfg_files
% Image Calculator: Expression - cfg_entry
nrun = 1; % enter the number of runs here
jobfile=cellstr(fullfile(baseDir,'JOB_FILES/SUV_IMCALC_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(renamedCOUNTfile); % Image Calculator: Input Images - cfg_files
    inputs{2, crun} = sprintf('(i1*%f)',SPM8_Bqperml_SUV); % Image Calculator: Expression - cfg_entry
    end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});


  SUVfile = fullfile(dir_dicom,'SUV.nii');
  renamedSUVfile=strcat(dir_dicom,'/','SUV_',subj_code,'.nii');
  copyfile(SUVfile, renamedSUVfile);
  delete(SUVfile);
  mkdir SUV;
  movefile (renamedSUVfile, 'SUV');
  
  
  
  cd SUV;
