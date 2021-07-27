%declaring useful variables
global baseDir
global subj_code
global dir_pat

cd(fullfile (dir_pat,'SPM'));
smoothedImg=strcat(dir_pat,'/','SPM','/','swcounts_',subj_code,'.nii');
rendFile=fullfile(baseDir,'OTHER_FUNCTIONS/render_spm96.mat');

% List of open inputs
% Results Report: Select SPM.mat - cfg_files
nrun = 1; % enter the number of runs here
jobfile = cellstr(fullfile(baseDir,'JOB_FILES/STAT_script_addon_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(fullfile(dir_pat,'SPM','SPM.mat')); % Results Report: Select SPM.mat - cfg_files
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});

spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',   xSPM.Z ,'mat', xSPM.M,'dim', xSPM.DIM),1,rendFile,0);
%export_fig 'Pres_render_new.jpg'; %saves render as jpeg (get current figure!)
saveas(gcf, 'Render_pres_new.jpg');

spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',xSPM.Z,'mat', xSPM.M,'dim', xSPM.DIM),nan,rendFile)
%export_fig 'Pres_render_old.jpg'
saveas(gcf, 'Render_pres_old.jpg');

template_T1= strcat(baseDir,'/MASK_TEMPLATES_HC/single_subj_T1.nii');
hypo_nii = strcat(dir_pat,'/SPM/spmT_0001_Hypo.nii');
pres_nii = strcat(dir_pat,'/SPM/spmT_0002_Pres.nii');

%inputs should be char, but not possible to concatenate chars of different
%length; creating a matrix containing cells first, and then converting to
%char
images=[{template_T1};{hypo_nii};{pres_nii}];
slover_singlesubj_DOC_ax(char(images))
