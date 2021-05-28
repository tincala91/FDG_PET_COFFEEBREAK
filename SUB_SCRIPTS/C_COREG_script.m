% List of open inputs
% Coregister: Estimate: Reference Image - cfg_files
% Coregister: Estimate: Source Image - cfg_files


%declaring useful variables
global baseDir
global subj_code
dir_dicom=pwd;
renamedCOUNTfile=strcat(dir_dicom,'\','counts_',subj_code,'.nii');
templateFDG=fullfile(baseDir,'MASK_TEMPLATES_HC\TemplateCtac8_8_2011.img');

nrun = 1; % enter the number of runs here
jobfile = cellstr(fullfile(baseDir,'JOB_FILES\COREG_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);

for crun = 1:nrun
    inputs{1, crun} = cellstr(templateFDG); % Coregister: Estimate: Reference Image - cfg_files
    inputs{2, crun} = cellstr(renamedCOUNTfile); % Coregister: Estimate: Source Image - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});

spm_check_registration(renamedCOUNTfile,templateFDG);
saveas(gcf,sprintf('2_SET_ORIGIN_COREG.png'),'bmp') ;
