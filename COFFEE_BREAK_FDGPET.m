
%COFFE_BREAK_FDGPET SCRIPT TO DERIVE SINGLE SUBJECT FDG_PET RESULTS IN THE CLINICS

%Authors: Arianna Sala (ULIEGE, CHULiege), Andreas Schindele (Universitätsklinikum Augsburg) 

%Contributors: 
% Mohamed Ali Bahri (ULIEGE; extraction of global SUV); 
% Claire Bernard (CHULiege; extraction of dicom information and computation of SUV images);
% Matthew Brett, John Ashburner (SPM render functions);
% Jøger Hansegård (isdicom function);
% Chris Rordern (USC; setting origin script); 
% Jimmy Shen (nifti functions from TFCE toolbox);
% Oliver J. Woodford, Yair M. Altman (figure export function);
% REX toolbox was obtained from https://web.mit.edu/swg/software.htm

%The script allows to obtain with a single click and starting from the patient's original DICOM images 
%(i) an estimate of the average reduction of the patient's brain GM metabolism; 
%(ii) single-subject maps of relative hypometabolism vs. preserved metabolism; 
%(iii) a standardized report on the topography of hypometabolism and preserved metabolism at regional and network level.

%SETUP:

%0) DOWNLOAD THE SCRIPT ON YOUR COMPUTER

%1) ADD NIFTI FILES OF 33HC TO THE MASK_TEMPLATES_HC. THESE FILES CAN BE
%DOWNLOADED FROM: https://search.kg.ebrains.eu/live/minds/core/dataset/v1.0.0/68a61eab-7ba9-47cf-be78-b9addd64bb2f

%2) CHANGE DIRECTORY TO THE SCRIPT FOLDER AND TYPE 'COFFEE_BREAK_FDG" IN
%THE COMMAND PROMPT; PRESS ENTER

%Please note that the script should be run by experienced users and quality checks should be performed after the script has run; 
%please refer to the material available here for more information:
%https://indico.giga.uliege.be/e/FDG-PET-2021, talks by Jitka Annen
%(Quality Check) and Andreas Schindele

global JOB_DIR
global TEMPLATE_DIR
global xSPM

full_path = mfilename('fullpath');
[baseDir, fn, e] = fileparts(full_path);

cur_path = pwd();

JOB_DIR = fullfile(baseDir, 'JOB_FILES'); 
TEMPLATE_DIR = fullfile(baseDir, 'MASK_TEMPLATES_HC'); 
ROI_DIR = fullfile(baseDir, 'ROIs');

addpath(fullfile(baseDir, 'OTHER_FUNCTIONS'));
addpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'TFCE'));
addpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'export_fig-master'));

%selects the directory containing only dicoms 
dir_path = spm_select(1,'dir', 'Select directory where DICOM files are'); %% input directory

%dir_path = '/home/andreas/Work/UKA/SPM_2022/SPM/Test';

try 

  %extract SUV value from DICOM infos, import dicom;
  %saves patients info
  %run(fullfile(baseDir, 'SUB_SCRIPTS', 'A_DICOM_INFO.m'));
  [fname, sub_info] = A_DICOM_INFO(dir_path);

  %automatically sets the origin in the anterior commissure (please check
  %that the image is co-registered to the template!
  [fnames, coivox] = B_nii_setOriginCOM(fname);

  fnames = C_COREG_script(fnames, fullfile(TEMPLATE_DIR, 'TemplateCtac8_8_2011.img'));

  %normalizes image to template and smooths
  fnames = D_NORMA_script(fnames, fullfile(TEMPLATE_DIR, 'TemplateCtac8_8_2011.img'));

  %compares swSUV image to HC, then saves results of hypo and pres contrasts
  controls = spm_select('FPlist', 'data/HC_IMAGES/', '^sws.*\.img$');
  if size(controls, 1) < 10
    error('Found too little of HC images');
  end

  render = fullfile(baseDir, 'OTHER_FUNCTIONS', 'render_spm96.mat');
  spm_mat = E_STAT_script(...
                fnames, render, ...
                fullfile(TEMPLATE_DIR, 'brainmask.nii'), ...
                controls);
  E_STAT_script_addon(spm_mat, render,...
                      fullfile(TEMPLATE_DIR, 'single_subj_T1.nii'));

  %extract and saves info on topography of hypometabolism and of preserved
  %regions
  conditions = spm_select('FPlist', fullfile(dir_path, 'SPM'), ...
                          '^spmT_[0-9]{4}_[0-9a-zA-Z]+\.nii$');
  F_percent(conditions, ...
            fullfile(dir_path, 'SPM', 'mask.nii'), ...
            fullfile(ROI_DIR, 'aal_all_regions.img'), ...
            fullfile(ROI_DIR, 'percent_regions.xlsx'),...
            2, 'C');

  regions = {...
    fullfile(ROI_DIR,'FRONTAL_L.img'); ...
    fullfile(ROI_DIR,'FRONTAL_R.img'); ...
    fullfile(ROI_DIR,'PARIETAL_L.img'); ...
    fullfile(ROI_DIR,'PARIETAL_R.img'); ...
    fullfile(ROI_DIR,'OCCIPITAL_L.img');...
    fullfile(ROI_DIR,'OCCIPITAL_R.img');...
    fullfile(ROI_DIR,'TEMPORAL_L.img');...
    fullfile(ROI_DIR,'TEMPORAL_R.img');...
    fullfile(ROI_DIR,'INSULA_L.img');...
    fullfile(ROI_DIR,'INSULA_R.img');...
    fullfile(ROI_DIR,'BASAL_GANGLIA.img');...
    fullfile(ROI_DIR,'THALAMUS.img');...
    fullfile(ROI_DIR,'BRAINSTEM.img');...
    fullfile(ROI_DIR,'CBL.img')...
    };

  F_percent(conditions, ...
            fullfile(dir_path, 'SPM', 'mask.nii'), ...
            regions, ...
            fullfile(ROI_DIR, 'percent_lobes.xlsx'), ...
            2, 'B');

  F_percent(conditions, ...
            fullfile(dir_path, 'SPM', 'mask.nii'), ...
            fullfile(ROI_DIR,'CAREN_5RSNS.nii'), ...
            fullfile(ROI_DIR, 'percent_networks.xlsx'), ...
            2, 'B');
  regions = {...
    fullfile(ROI_DIR,'1_IFG_OPER.img'); ...
    fullfile(ROI_DIR,'2_IFG_TRIANGULAR.img');...
    fullfile(ROI_DIR,'3_SUPRAMARGINAL.img');...
    fullfile(ROI_DIR,'4_ANGULAR.img');...
    fullfile(ROI_DIR,'5_TEMP_SUP_POST.nii');...
    fullfile(ROI_DIR,'6_TEMP_MID_POST.nii');...
    fullfile(ROI_DIR,'7_TEMP_INF_POST.nii')...
    };
  F_percent(conditions, ...
            fullfile(dir_path, 'SPM', 'mask.nii'), ...
            regions, ...
            fullfile(ROI_DIR, 'percent_language.xlsx'), ...
            2, 'B');

  if sub_info.correct_unit
      %compute SUV image;
      G_SUV_WRITE(dir_path, sub_info);

      %normalizes image to template and smooths
      H_NORMA_script(dir_path, sub_info);

      %extract mean SUV in the GM of the wSUV image
      %saves SUV information and computes mean SUV decrease (compared to
      %controls)
      %creates render in MRIcron style
      I_SUV_GM_script(dir_path, sub_info);
  end

catch ME
  rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS'));
  rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'TFCE'));
  rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'export_fig-master'));
  cd(cur_path);
  save('workspace_dump.m');
  rethrow(ME);
end

rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS'));
rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'TFCE'));
rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'export_fig-master'));

clear JOB_DIR;
clear TEMPLATE_DIR;
clear xSPM
