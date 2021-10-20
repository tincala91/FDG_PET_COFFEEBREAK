
% List of open inputs
% Old Normalise: Estimate & Write: Source Image - cfg_files
% Old Normalise: Estimate & Write: Images to Write - cfg_files
nrun = 1; % enter the number of runs here

%declaring useful variables
global baseDir
global subj_code
global dir_pat

cd(fullfile (dir_pat,'SPM'));
renamedCOUNTfile=strcat(dir_pat,'/','SPM','/','counts_',subj_code,'.nii');

jobfile = cellstr(fullfile(baseDir,'JOB_FILES/NORMA_script_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(renamedCOUNTfile); % Old Normalise: Estimate & Write: Source Image - cfg_files
    inputs{2, crun} = cellstr(renamedCOUNTfile); % Old Normalise: Estimate & Write: Images to Write - cfg_files
    inputs{3, crun} = cellstr(fullfile(baseDir,'MASK_TEMPLATES_HC/TemplateCtac8_8_2011.img')); % Old Normalise: Estimate & Write: Template Image - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});


