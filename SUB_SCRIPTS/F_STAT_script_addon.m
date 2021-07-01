%declaring useful variables
global baseDir
global subj_code
global dir_dicom

cd(dir_dicom);
%dir_dicom=pwd;
smoothedImg=strcat(dir_dicom,'/','swcounts_',subj_code,'.nii');
rendFile=fullfile(baseDir,'MASK_TEMPLATES_HC/render_spm96.mat');

% List of open inputs
% Results Report: Select SPM.mat - cfg_files
nrun = 1; % enter the number of runs here
jobfile = cellstr(fullfile(baseDir,'JOB_FILES/STAT_script_addon_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(fullfile(dir_dicom,'SPM.mat')); % Results Report: Select SPM.mat - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});

spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',   xSPM.Z ,'mat', xSPM.M,'dim', xSPM.DIM),1,rendFile,0);
%export_fig 'Pres_render.jpg'; %saves render as jpeg (get current figure!)
saveas(gcf, 'Pres_render.jpg');

rendFile=fullfile(baseDir,'MASK_TEMPLATES_HC/render_spm96.mat');
spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',xSPM.Z,'mat', xSPM.M,'dim', xSPM.DIM),nan,rendFile)
%export_fig 'Pres_render_old.jpg'
saveas(gcf, 'Pres_render.jpg');

hypo_nii = strcat(dir_dicom, '/spmT_0001_Hypo.nii');
pres_nii = strcat(dir_dicom, '/spmT_0002_Pres.nii');

slover_singlesubj_DOC_ax([hypo_nii; pres_nii])