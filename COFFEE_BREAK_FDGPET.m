
%SINGLE SUBJECT FDG_PET IN THE CLINICS. Author: Arianna Sala

% The script allows to obtain with a single click and starting from the patient's original DICOM images 
%(i) an estimate of the average reduction of the patient's brain GM metabolism; 
%(ii) single-subject maps of relative hypometabolism vs. preserved metabolism; 
%(iii) a standardized report on the topography of hypometabolism and preserved metabolism at regional and network level.

%SETUP:

%0) DOWNLOAD THE SCRIPT FOLDER FROM THE Y ON YOUR COMPUTER

%1) THE DIRECTORY "SCRIPT" WITHIN THE COFFEE_BREAK_FDGPET FOLDER  NEEDS TO BE ADDED TO THE MATLAB
%PATH. CLICK HOME>SET PATH>ADD WITH SUBFOLDERS, THEN SELECT THE SCRIPT FOLDER ON YOUR COMPUTER

%2) OPEN THE SCRIPT COFFEE_BREAK_FDGPET.m IN MATLAB AND REPLACE 'CHANGEMEPLEASE'AT LINE 42 WITH THE PATH TO
%THE SCRIPT FOLDER ON YOU COMPUTER (the folder where you downloaded the SCRIPT folder), e.g. C:\Tpol\Desktop\COMA\SCRIPT

%3) OPEN THE STAT_script_job.m IN SCRIPT\JOB_FILES AND DO THE SAME (use the "Find" function in Matlab to
%replace every CHANGEMEPLEASE in one click)

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


function COFFEE_BREAK_FDGPET()

global baseDir
baseDir='C:\Users\asala\Desktop\SCRIPT'; 
%%***please replace C:\Users\asala\Desktop\SCRIPT with the path to the script folder!***


%selects the directory containing only dicoms 
dir_dicom = spm_select(1,'dir', 'Select directory where DICOM files are'); %% input directory
cd(dir_dicom);
clear dir_dicom;
save baseDir;

%extract SUV value from DICOM infos, import dicom and compute SUV image;
%saves patients info
run('A_SUV_COMP.m')

%automatically sets the origin in the anterior commissure (please check
%that the image is co-registered to the template!
run('B_nii_setOriginCOM.m')
run('C_COREG_script.m')

%normalizes image to template and smooths
run('D_NORMA_script.m')

%extract mean SUV in the GM of the wSUV image
%saves SUV information and computes mean SUV decrease (compared to
%controls)
run('E_SUV_GM_script.m')

%compares swSUV image to HC, then saves results of hypo and pres contrasts
run('F_STAT_script.m')

%extract and saves info on topography of hypometabolism and of preserved
%regions
run('G_percent_regions.m');
run('G_percent_lobes.m');
run('G_percent_networks.m');
run('G_percent_language.m');

clear all

end