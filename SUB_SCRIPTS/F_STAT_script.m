%declaring useful variables
global baseDir
global subj_code
global dir_dicom

cd(dir_dicom);
%dir_dicom=pwd;
smoothedImg=strcat(dir_dicom,'/','swcounts_',subj_code,'.nii');
rendFile=fullfile(baseDir,'MASK_TEMPLATES_HC/render_spm96.mat');
list_HC={(fullfile(baseDir,'MASK_TEMPLATES_HC/sws0042855A-207260-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws0055474Q-419110-00001-000001.img'))
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws0152256K-866740-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws0228866K-714870-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws0317717H-340790-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws0502130L-831340-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws0582584R-898820-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws0625676B-306400-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws3310574Q-58250-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws6031272L-14440-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/sws6254700X-582150-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900065-95220-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900066-121980-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900070-308360-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900071-157440-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900075-386980-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900082-520830-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900083-568840-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900084-393230-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900085-427300-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900088-563330-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900094-552000-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900095-731030-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900096-767100-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900097-584700-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900106-988230-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900124-288560-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900126-120750-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900130-483320-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900146-893690-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900147-919340-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900148-761150-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900158-980670-00001-000001.img'));
                                                            (fullfile(baseDir,'MASK_TEMPLATES_HC/swsGERA2900169-306710-00001-000001.img'))}


% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Group 1 scans - cfg_files
nrun = 1; % enter the number of runs here
jobfile = cellstr(fullfile(baseDir,'JOB_FILES/STAT_script_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(dir_dicom); % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = cellstr(smoothedImg); % Factorial design specification: Group 1 scans - cfg_files
    inputs{3, crun} = cellstr(list_HC); %Factorial design specification: Group 2 scans - cfg_files
    inputs{4, crun} = cellstr(fullfile(baseDir,'MASK_TEMPLATES_HC/brainmask.nii')); %Factorial design specification: mask - cfg_files
    end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});

spm_render_DOC(struct('XYZ', xSPM.XYZ, 't',   xSPM.Z','mat', xSPM.M,'dim', xSPM.DIM),nan,rendFile);
spm_figure('colormap', 'gray-cool'); %change colormaps to cool for hypo
saveas(gcf, 'Hypo_render.jpg'); %saves render as jpeg (get current figure!)
