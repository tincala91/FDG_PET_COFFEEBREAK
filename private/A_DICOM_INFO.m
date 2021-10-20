%This function was originally provided by Claire Bernanrd (Nucl Med
%Department) and modified subsequanetly

%NOTE: THIS WORKS ONLY FOR FDG_PET IMAGES ACQUIRED WITH THE CHU SCANNER(Gemini TF CT scanner (Philips Medical Systems)

function [sub_file, scale] = A_DICOM_INFO(dir_path, nrun)

%declaring useful variables
global JOB_DIR

%% Sélectio\n des fichiers à analyser

fprintf('Analysing directory %s\n', dir_path);

% If there a parameter that user may change or adjust
% it must be passed to function as (optional) argument
% BTW, what nrun do exctly?
if ~exist('nrun', 'var')
  nrun = 1;
end


name_dicom = get_dicoms(dir_path);

move_dicoms = true;
if isempty(name_dicom)
  % Checking if folder DICOM exists
  if exist(fullfile(dir_path, 'DICOM'))
    name_dicom = get_dicoms(fullfile(dir_path, 'DICOM'));
    move_dicoms = false;
  end
end

if isempty(name_dicom)
  error('Folder %s don''t contain valid dicom files', dir_path);
end

sub_info = get_sub_info(name_dicom{1});
scale = sub_info.scale;

writetable(sub_info.table,fullfile(dir_path, 'PET_info.xlsx'));

%DICOM IMPORT

% List of open inputs
% DICOM Import: DICOM files - cfg_files
% DICOM Import: Output directory - cfg_files
jobfile=fullfile(JOB_DIR, 'DICOM_IMP_job.m');
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = name_dicom; % DICOM Import: DICOM files - cfg_files
    inputs{2, crun} = cellstr(dir_path); % DICOM Import: Output directory - cfg_files
end

spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});

if move_dicoms
  %move dicom in a dedicated folder, to keep a bit of order
  dicom_dir = fullfile(dir_path, 'DICOM', '.');
  if ~exist(dicom_dir, 'dir')
    mkdir(dicom_dir);
  end

  for i=1:size(name_dicom, 1)
      movefile(name_dicom{i, 1}, dicom_dir);
  end
end

%CHANGE FILE NAME TO NIFTI

%get nifti filename

list_nifti=dir(fullfile(dir_path, 's*.nii'));

if size(list_nifti, 1) ~= 1
  error('Several s*.nii files found');
end

%change name to match patient's record
COUNTfile = list_nifti.name;
renamedCOUNTfile = ['counts_' sub_info.code '.nii'];
sub_file = fullfile(dir_path, renamedCOUNTfile);

fprintf('Renaming file %s to %s\n', COUNTfile, renamedCOUNTfile);
movefile(fullfile(dir_path, COUNTfile), sub_file);
    
end
  
function dicoms = get_dicoms(path)
  % Retrive the list of valid dicom files from path

  dicoms = {};
  flist = dir(path);

  for i=1:length(flist)
    if flist(i).isdir 
      continue;
    end
    fname = fullfile(flist(i).folder, flist(i).name);
    if isdicom(fname) 
      dicoms{end + 1, 1} = fname;
    end
  end
end

function sub_info = get_sub_info(fname)
  sub_info = [];

  info=dicominfo(fname);
  FN=info.PatientName; 
  if ~isfield(FN,'GivenName')
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
      fprintf('RescaleItercept == %f; not null', info.RescaleIntercept)
  end
  fprintf('Patient: %s-%s, born %s\n', FN.FamilyName, FN.GivenName, num2str(DN));
  fprintf('Exam: %s at %s; unit: %s\n', num2str(DE), num2str(HeureExam), Unite);
  fprintf('Weight: %s kg;\n', num2str(weight));
  fprintf('Dose: %s %s, measured at %s\n', num2str(Dose), num2str(Unite), num2str(HeureMesure));

  hours_mes = floor(HeureMesure/1e4);
  min_mes = floor((HeureMesure - hours_mes*1e4)/1e2);
  sec_mes = HeureMesure - hours_mes*1e4 - min_mes*1e2;

  hours_exa = floor(HeureExam/1e4);
  min_exa = floor((HeureExam - hours_exa*1e4)/1e2);
  sec_exa = HeureExam - hours_exa*1e4 - min_exa*1e2;

  Time_difference = (hours_exa*3600 + min_exa*60 + sec_exa - hours_mes*3600 - min_mes*60 - sec_mes);
  decay_dose = Dose * 2^(-(Time_difference/6586.2));
  scaling_factor = weight * 1000 / decay_dose;

  sub_info.correct_unit = true;
  if ~strcmp(Unite, 'BQML')
    if isfield(info, 'Private_7053_1000')
      scaling_factor = info.Private_7053_1000/info.RescaleSlope;
    else
      sub_info.correct_unit = false;
      warning('The Unit is not BQML. SUV will not be calculated');
    end
  end
  sub_info.scale = scaling_factor;

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
  SUVparam_Imcalc=convertCharsToStrings(sub_info.scale);
  if sub_info.correct_unit
      sub_info.table= table(Surname, Name, Date_of_birth,...
                            Date_of_PET, Time_of_PET,...
                            Weight, Unit_Weight,...
                            Dose, Unit,...
                            Time_Measurement_Dose, SUVparam_Imcalc);
  else
      sub_info.table=table(Surname, Name, Date_of_birth,...
                           Date_of_PET, Time_of_PET,...
                           Weight, Unit_Weight,...
                           Dose, Unit,...
                           Time_Measurement_Dose);
  end
  sub_info.code=[FN.FamilyName(1:2), FN.GivenName(1:2),'_',num2str(DN),'_',num2str(DE)];
end
