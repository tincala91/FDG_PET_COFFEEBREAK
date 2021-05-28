%This function was originally provided by Claire Bernanrd (Nucl Med
%Department) and modified subsequanetly

%NOTE: THIS WORKS ONLY FOR FDG_PET IMAGES ACQUIRED WITH THE CHU SCANNER(Gemini TF CT scanner (Philips Medical Systems)

function A_SUV_COMP()

%declaring useful variables
global baseDir
global subj_code
global SPM8_Bqperml_SUV

%% Sélectio\n des fichiers à analyser
dir_dicom=pwd
defaultFileName=fullfile(dir_dicom,'*.dcm');
list_dicom=dir(dir_dicom)
list_dicom=list_dicom(3:length(list_dicom))
firstDicom=list_dicom(1).name;
if isempty(firstDicom)
    % User clicked the Cancel button.
    return;
end
%% Lecture des données
fullFileName=cellstr(fullfile(dir_dicom,firstDicom));

info=dicominfo(fullFileName{1});

FN=info.PatientName; 
if isfield(FN,'GivenName')==0
    FN.GivenName='  ';
end
DN=info.PatientBirthDate;
Unite=info.Units;
%DE=info.InstanceCreationDate;
DE=info.AcquisitionDate;
Poids=info.PatientWeight;
Dose=info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose/1000000.0;
HeureMesure=info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime;
HeureExam=info.SeriesTime;

if info.RescaleIntercept~=0
    printf('RescaleItercept non nul ',info.RescaleIntercept)
end
strcat(FN.FamilyName,'-',FN.GivenName, ' née :  ', num2str(DN))

strcat('Date Examen :  ',num2str(DE),' à :',num2str(HeureExam),' ; unité :  ',Unite)

strcat('Poids : ',num2str(Poids),' kg ;', num2str(Dose),' MBq mesuré à :',num2str(HeureMesure))

SPM8_Bqperml_SUV=info.Private_7053_1000/info.RescaleSlope
[info.RescaleSlope;info.Private_7053_1000]

%save basic data in a summary xls file
Surname=convertCharsToStrings(FN.FamilyName);
Name=convertCharsToStrings(FN.GivenName);
Date_of_birth=convertCharsToStrings(DN);
Date_of_PET=convertCharsToStrings(DE);
Time_of_PET=convertCharsToStrings(HeureExam);
Unit=convertCharsToStrings(Unite);
Weight=convertCharsToStrings(Poids);
Unit_Weight=convertCharsToStrings('kg');
Dose=convertCharsToStrings(Dose);
Time_Measurement_Dose=convertCharsToStrings(HeureMesure);
Rescale_Slope=convertCharsToStrings(info.RescaleSlope);
Private=convertCharsToStrings(info.Private_7053_1000);
SUVparam_Imcalc=convertCharsToStrings(SPM8_Bqperml_SUV);

SUV_info=table(Surname, Name, Date_of_birth, Date_of_PET, Time_of_PET, Unit, Weight,Unit_Weight,Dose,Time_Measurement_Dose,Rescale_Slope,Private, SUVparam_Imcalc);

writetable(SUV_info,'1_PET_info.xlsx');

%DICOM IMPORT

for i=1:length(list_dicom)
nDicom=list_dicom(i).name;
fullFileName=cellstr(fullfile(dir_dicom,nDicom));
allDicom(i)=fullFileName;
end

allDicom=allDicom';
allDicom=char(allDicom);

% List of open inputs
% DICOM Import: DICOM files - cfg_files
% DICOM Import: Output directory - cfg_files
nrun = 1; % enter the number of runs here
jobfile=cellstr(fullfile(baseDir,'JOB_FILES\DICOM_IMP_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(allDicom); % DICOM Import: DICOM files - cfg_files
    inputs{2, crun} = cellstr(dir_dicom); % DICOM Import: Output directory - cfg_files
end

spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});

%move dicom in a dedicated folder, to keep a bit of order
mkdir DICOM
movefile('*.dcm','DICOM');

%CHANGE FILE NAME TO NIFTI

%get nifti filename

list_nifti=dir('*.nii');

%change name to match patient's record
  subj_code=[FN.FamilyName(1:2), FN.GivenName(1:2),'_',num2str(DN),'_',num2str(DE)];
  COUNTfile = list_nifti.name;
  renamedCOUNTfile=strcat(dir_dicom,'\','counts_',subj_code,'.nii');
  copyfile(COUNTfile, renamedCOUNTfile);
      
  clearvars -except subj_code 
  save subj_code
  
  
  
