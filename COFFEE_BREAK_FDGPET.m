
%COFFE_BREAK_FDGPET SCRIPT TO DERIVE SINGLE SUBJECT FDG_PET RESULTS IN THE CLINICS
%Authors: Arianna Sala (ULIEGE, CHU), Andreas Schindele (Universitätsklinikum Augsburg) 
%Contributors: Claire Bernard (CHU Liege; SUV_computation); Chris Rordern (USC; nii_setOriginCOM)

%The script allows to obtain with a single click and starting from the patient's original DICOM images 
%(i) an estimate of the average reduction of the patient's brain GM metabolism; 
%(ii) single-subject maps of relative hypometabolism vs. preserved metabolism; 
%(iii) a standardized report on the topography of hypometabolism and preserved metabolism at regional and network level.

%SETUP:

%0) DOWNLOAD THE SCRIPT FOLDER FROM THE Y ON YOUR COMPUTER

%1) THE DIRECTORY "SCRIPT" WITHIN THE COFFEE_BREAK_FDGPET FOLDER  NEEDS TO BE ADDED TO THE MATLAB
%PATH. CLICK HOME>SET PATH>ADD WITH SUBFOLDERS, THEN SELECT THE SCRIPT FOLDER ON YOUR COMPUTER

%DONE!!! NOW THE SCRIPT IS READY TO RUN. FROM NOW ON YOU WILL JUST HAVE TO TYPEE COFFE_BREAK_FDGPET AND
%PRESS ENTER IN MATLAB EVERY TIME YOU WANT TO RUN THE SCRIPT. 

%THE SCRIPT WILL JUST ASK YOU TO SELECT THE FOLDER WITH THE DICOM FILES.
%ONLY DICOM FILES MUST BE IN THE FOLDER, NOTHING ELSE!

%BEFORE LOOKING AT THE RESULTS, ALWAYS CHECK THE INTERMEDIATE OUTPUT FILES TO ENSURE THAT NOTHING
%WENT WRONG!!! 

%SEE THE INTRODUCTORY SLIDES FOR MORE INFO!

%For questions, suggestions and if mysterious errors occur please report
%them on https://github.com/tincala91/COFFEE_BREAK_FDGPET (you need to
%register on github first, then send me an email with your usarname to get
%access - arianna.sala@uliege.be)

global baseDir
global dir_dicom

addpath(fullfile(baseDir, 'OTHER_FUNCTIONS'))

full_path = mfilename('fullpath')
[baseDir, fn, e] = fileparts(full_path)

%selects the directory containing only dicoms 
dir_dicom = spm_select(1,'dir', 'Select directory where DICOM files are'); %% input directory
%cd(dir_dicom);
%clear dir_dicom;
save baseDir;

%extract SUV value from DICOM infos, import dicom;
%saves patients info
run(fullfile(baseDir, 'SUB_SCRIPTS/A_SUV_COMP.m'))

%automatically sets the origin in the anterior commissure (please check
%that the image is co-registered to the template!
run(fullfile(baseDir, 'SUB_SCRIPTS/B_nii_setOriginCOM.m'))
run(fullfile(baseDir, 'SUB_SCRIPTS/C_COREG_script.m'))

%normalizes image to template and smooths
run(fullfile(baseDir, 'SUB_SCRIPTS/D_NORMA_script.m'))

%compares swSUV image to HC, then saves results of hypo and pres contrasts
run(fullfile(baseDir, 'SUB_SCRIPTS/F_STAT_script.m'))
run(fullfile(baseDir, 'SUB_SCRIPTS/F_STAT_script_addon.m'))


%extract and saves info on topography of hypometabolism and of preserved
%regions
run(fullfile(baseDir, 'SUB_SCRIPTS/G_percent_regions.m'));
run(fullfile(baseDir, 'SUB_SCRIPTS/G_percent_lobes.m'));
run(fullfile(baseDir, 'SUB_SCRIPTS/G_percent_networks.m'));
run(fullfile(baseDir, 'SUB_SCRIPTS/G_percent_language.m'));

%compute SUV image;
run(fullfile(baseDir, 'SUB_SCRIPTS/H_SUV_WRITE.m'))

%normalizes image to template and smooths
run(fullfile(baseDir, 'SUB_SCRIPTS/I_NORMA_script.m'))

%extract mean SUV in the GM of the wSUV image
%saves SUV information and computes mean SUV decrease (compared to
%controls)
%creates render in MRIcron style
run(fullfile(baseDir, 'SUB_SCRIPTS/E_SUV_GM_script.m'))

rmpath(fullfile(baseDir, 'OTHER_FUNCTIONS'))
clear all