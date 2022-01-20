
function H_NORMA_script(dir_path, sub_info)

% List of open inputs
% Old Normalise: Estimate & Write: Source Image - cfg_files
% Old Normalise: Estimate & Write: Images to Write - cfg_files
nrun = 1; % enter the number of runs here

%declaring useful variables
global JOB_DIR
global TEMPLATE_DIR

cd(fullfile(dir_path, 'SUV'))
%dir_dicom=pwd;
renamedSUVfile=strcat(dir_path,'/','SUV/SUV_',sub_info.code,'.nii');

jobfile = cellstr(fullfile(JOB_DIR,'NORMA_script_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(renamedSUVfile); % Old Normalise: Estimate & Write: Source Image - cfg_files
    inputs{2, crun} = cellstr(renamedSUVfile); % Old Normalise: Estimate & Write: Images to Write - cfg_files
    inputs{3, crun} = cellstr(fullfile(TEMPLATE_DIR,'TemplateCtac8_8_2011.img')); % Old Normalise: Estimate & Write: Template Image - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});


