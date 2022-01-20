function G_SUV_WRITE(dir_path, sub_info)

%declaring useful variables
global JOB_DIR

%dir_path=pwd;
cd(fullfile (dir_path,'SPM'));
renamedCOUNTfile=strcat(dir_path,'/','SPM','/','counts_',sub_info.code,'.nii');

% List of open inputs
% Image Calculator: Input Images - cfg_files
% Image Calculator: Expression - cfg_entry
nrun = 1; % enter the number of runs here
jobfile=cellstr(fullfile(JOB_DIR ,'SUV_IMCALC_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(renamedCOUNTfile); % Image Calculator: Input Images - cfg_files
    inputs{2, crun} = sprintf('(i1*%f)',sub_info.scale); % Image Calculator: Expression - cfg_entry
    end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});


SUVfile = fullfile(dir_path,'SPM','SUV.nii');
renamedSUVfile=strcat(dir_path,'/','SPM','/','SUV_',sub_info.code,'.nii');
copyfile(SUVfile, renamedSUVfile);
delete(SUVfile);
cd(dir_path)
mkdir SUV;
movefile (renamedSUVfile, 'SUV'); 
cd SUV;
