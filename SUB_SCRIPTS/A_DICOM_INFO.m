%This function was originally provided by Claire Bernanrd (Nucl Med
%Department) and modified subsequanetly

%NOTE: THIS WORKS ONLY FOR FDG_PET IMAGES ACQUIRED WITH THE CHU SCANNER(Gemini TF CT scanner (Philips Medical Systems)

function A_DICOM_INFO()

%declaring useful variables
global baseDir
global dir_pat
global subj_code
global SPM8_Bqperml_SUV
global Correct_unit

%% Sélectio\n des fichiers à analyser

Correct_unit = 1;
cd(dir_pat);
save baseDir;
%dir_pat=pwd
%defaultFileName=fullfile(dir_pat,'*.dcm');
list_dicom=dir(dir_pat);
list_dicom=list_dicom(3:end);


name_dicom = strings(length(list_dicom));
values = zeros(length(list_dicom));
for i=1:length(list_dicom)
    list_dicom(i).name ;
    if ~list_dicom(i).isdir 
        if isdicom(list_dicom(i).name) 
            name_dicom(i) = list_dicom(i).name;
            values(i) = 1;
        end
    end
end

name_dicom = name_dicom(logical(values));
    


firstDicom=name_dicom(1);
if isempty(firstDicom)
    % User clicked the Cancel button.
    return;
end
%% Lecture des données
fullFileName=cellstr(fullfile(dir_pat,firstDicom));

info=dicominfo(fullFileName{1});

FN=info.PatientName; 
if isfield(FN,'GivenName')==0
    FN.GivenName='  ';
end
DN=info.PatientBirthDate;
Unite=info.Units;


%DE=info.InstanceCreationDate;
DE=info.AcquisitionDate;
weight = info.PatientWeight;
Dose=info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
HeureMesure=str2double(info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
HeureExam=str2double(info.SeriesTime);

if info.RescaleIntercept~=0
    printf('RescaleItercept non nul ',info.RescaleIntercept)
end
strcat(FN.FamilyName,'-',FN.GivenName, ' née :  ', num2str(DN))

strcat('Date Examen :  ',num2str(DE),' à :',num2str(HeureExam),' ; unité :  ',Unite)

strcat('Poids : ',num2str(weight),' kg ;', num2str(Dose), num2str(Unite), ' mesuré à :',num2str(HeureMesure))

hours_mes = floor(HeureMesure/1e4);
min_mes = floor((HeureMesure - hours_mes*1e4)/1e2);
sec_mes = HeureMesure - hours_mes*1e4 - min_mes*1e2;

hours_exa = floor(HeureExam/1e4);
min_exa = floor((HeureExam - hours_exa*1e4)/1e2);
sec_exa = HeureExam - hours_exa*1e4 - min_exa*1e2;

Time_difference = (hours_exa*3600 + min_exa*60 + sec_exa - hours_mes*3600 - min_mes*60 - sec_mes);
decay_dose = Dose * 2^(-(Time_difference/6586.2));
scaling_factor = weight * 1000 / decay_dose;

if ~strcmp(Unite, 'BQML')
    if isfield(info, 'Private_7053_1000')==0
        Correct_unit = 0;
        warning('The Unit is not BQML. SUV will not be calculated');
    else
        scaling_factor = info.Private_7053_1000/info.RescaleSlope;
    end
end
SPM8_Bqperml_SUV = scaling_factor;
[info.RescaleSlope;scaling_factor];

%save basic data in a summary xls file
Surname=convertCharsToStrings(FN.FamilyName);
Name=convertCharsToStrings(FN.GivenName);
Date_of_birth=convertCharsToStrings(DN);
Date_of_PET=convertCharsToStrings(DE);
Time_of_PET=convertCharsToStrings(HeureExam);
Unit=convertCharsToStrings(Unite);
Weight=convertCharsToStrings(weight);
Unit_Weight=convertCharsToStrings('kg');
Dose=convertCharsToStrings(Dose);
Time_Measurement_Dose=convertCharsToStrings(HeureMesure);
%Private=convertCharsToStrings(info.Private_7053_1000);
SUVparam_Imcalc=convertCharsToStrings(SPM8_Bqperml_SUV);
if Correct_unit
    SUV_info=table(Surname, Name, Date_of_birth, Date_of_PET, Time_of_PET,Weight,Unit_Weight,Dose,Unit,Time_Measurement_Dose, SUVparam_Imcalc);
else
    SUV_info=table(Surname, Name, Date_of_birth, Date_of_PET, Time_of_PET,Weight,Unit_Weight,Dose,Unit,Time_Measurement_Dose);
end

writetable(SUV_info,'PET_info.xlsx');

%DICOM IMPORT

for i=1:length(list_dicom)
nDicom=list_dicom(i).name;
fullFileName=cellstr(fullfile(dir_pat,nDicom));
allDicom(i)=fullFileName;
end

allDicom=allDicom';
allDicom=char(allDicom);

% List of open inputs
% DICOM Import: DICOM files - cfg_files
% DICOM Import: Output directory - cfg_files
nrun = 1; % enter the number of runs here
jobfile=cellstr(fullfile(baseDir,'JOB_FILES/DICOM_IMP_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = cellstr(allDicom); % DICOM Import: DICOM files - cfg_files
    inputs{2, crun} = cellstr(dir_pat); % DICOM Import: Output directory - cfg_files
end

spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});

%move dicom in a dedicated folder, to keep a bit of order
mkdir DICOM
for i=1:length(name_dicom)
    movefile(name_dicom(i),'DICOM');
end

%CHANGE FILE NAME TO NIFTI

%get nifti filename

list_nifti=dir('*.nii');

%change name to match patient's record
  subj_code=[FN.FamilyName(1:2), FN.GivenName(1:2),'_',num2str(DN),'_',num2str(DE)];
  COUNTfile = list_nifti.name;
  renamedCOUNTfile=strcat(dir_pat,'/','counts_',subj_code,'.nii');
  copyfile(COUNTfile, renamedCOUNTfile);
      
  clearvars -except subj_code 
  save subj_code
  
  
  
