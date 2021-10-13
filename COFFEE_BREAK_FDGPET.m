
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

global baseDir
global dir_pat
global Correct_unit

cur_dir = pwd();

full_path = mfilename('fullpath');
[baseDir, fn, e] = fileparts(full_path);

addpath(fullfile(baseDir, 'OTHER_FUNCTIONS'));
addpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'TFCE'));
addpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'export_fig-master'));

%selects the directory containing only dicoms 
% dir_pat = spm_select(1,'dir', 'Select directory where DICOM files are'); %% input directory
%cd(dir_pat);
%clear dir_pat;
%save baseDir;
dir_pat = '/home/beliy/Works/COFFEE_BREAK_FDGPET/data/patients_images_dicom_fully_anonymized/FDGPET_PATIENT1';

try 

  %extract SUV value from DICOM infos, import dicom;
  %saves patients info
  %run(fullfile(baseDir, 'SUB_SCRIPTS', 'A_DICOM_INFO.m'));
  A_DICOM_INFO();

  %automatically sets the origin in the anterior commissure (please check
  %that the image is co-registered to the template!
  run(fullfile(baseDir, 'SUB_SCRIPTS/B_nii_setOriginCOM.m'))
  run(fullfile(baseDir, 'SUB_SCRIPTS/C_COREG_script.m'))

  %normalizes image to template and smooths
  run(fullfile(baseDir, 'SUB_SCRIPTS/D_NORMA_script.m'))

  %compares swSUV image to HC, then saves results of hypo and pres contrasts
  run(fullfile(baseDir, 'SUB_SCRIPTS/E_STAT_script.m'))
  run(fullfile(baseDir, 'SUB_SCRIPTS/E_STAT_script_addon.m'))


  %extract and saves info on topography of hypometabolism and of preserved
  %regions
  run(fullfile(baseDir, 'SUB_SCRIPTS/F_percent_regions.m'));
  run(fullfile(baseDir, 'SUB_SCRIPTS/F_percent_lobes.m'));
  run(fullfile(baseDir, 'SUB_SCRIPTS/F_percent_networks.m'));
  run(fullfile(baseDir, 'SUB_SCRIPTS/F_percent_language.m'));


  if Correct_unit
      %compute SUV image;
      run(fullfile(baseDir, 'SUB_SCRIPTS/G_SUV_WRITE.m'))

      %normalizes image to template and smooths
      run(fullfile(baseDir, 'SUB_SCRIPTS/H_NORMA_script.m'))

      %extract mean SUV in the GM of the wSUV image
      %saves SUV information and computes mean SUV decrease (compared to
      %controls)
      %creates render in MRIcron style
      run(fullfile(baseDir, 'SUB_SCRIPTS/I_SUV_GM_script.m'))
  end

catch ME
  rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS'))
  rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'TFCE'))
  rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'export_fig-master'))
  cd(cur_dir);
  rethrow(ME);
end

rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS'))
rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'TFCE'))
rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS', 'export_fig-master'))
clear all
