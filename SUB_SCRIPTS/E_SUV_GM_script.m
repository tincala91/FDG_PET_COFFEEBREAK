% -------------------------------------------------------------------------
% BATCH PET Data processing - MB - 24/01/2013
% Collaboration with COMA group
% -------------------------------------------------------------------------
% Script Usage: calculate the mean value on pet grey matter 
%
%
%
% Inputs :
% -------------------------------------------------------------------------
% - Select PET Images 
% - Select ROI Image (Pons Image)
% -------------------------------------------------------------------------
% Outputs :
% -------------------------------------------------------------------------
% - WPET* Mean calculation
%   outputs : mean_wPET

% -------------------------------------------------------------------------
% Inputs :
% -------------------------------------------------------------------------

%declaring useful variables
global baseDir
global subj_code
global dir_dicom

cd(fullfile(dir_dicom, 'SUV'))
%dir_dicom=pwd;
normImg=fullfile(strcat(dir_dicom,'/','SUV/wSUV_',subj_code,'.nii'));
ROI_file = fullfile(baseDir,'MASK_TEMPLATES_HC/MNI_grey_Mask.nii');

%[ROI_file,status] = spm_select(1, 'image', 'Select the Grey matter mask ', [], pwd); %% spm


job = 0;
spm pet
% -------------------------
% - GM mask creation
% -------------------------



	ima_files = cell(2,1);

	ima_files{1}=normImg;
    ima_files{2}=ROI_file(1,:);
	[pth,nam,ext] = fileparts(normImg);
    
    f='i1 .* (i2 > 0)';
    job = job + 1;

    
    matlabbatch{job}.spm.util{1}.imcalc.input =ima_files;
    matlabbatch{job}.spm.util{1}.imcalc.output = fullfile(pth,['' nam '_maskGM.nii']);
    matlabbatch{job}.spm.util{1}.imcalc.outdir = {''};
    matlabbatch{job}.spm.util{1}.imcalc.expression = f;
    matlabbatch{job}.spm.util{1}.imcalc.options.dmtx = 0;
    matlabbatch{job}.spm.util{1}.imcalc.options.mask = 0;
    matlabbatch{job}.spm.util{1}.imcalc.options.interp = 0;
    matlabbatch{job}.spm.util{1}.imcalc.options.dtype = 8;
	
    
% % ----------------------------
% % Run Part one of the batch
% % ----------------------------

    spm('Pointer','Watch');
    save('pet_norm_process_coma1.mat','matlabbatch');
    spm('Pointer');
	spm_jobman('serial',matlabbatch);

	clear matlabbatch;
    job = 0;    

 % ============================================================
 % Mean GM value for each subject

%fid = fopen('GM_values2.txt', 'w');
%fprintf(fid,'Filename \t GM Value \t Stdev\n');
ctrl = [];
C = cell(3,1);


    
    [pth,nam,ext] = fileparts(normImg);
    mask_file = fullfile(pth,['' nam '_maskGM.nii']);
    Ma = spm_vol(mask_file);
    temp = spm_read_vols(Ma);
    index = find(temp>0.0);
    GM = temp(index);
    
    value = mean(GM);
    stdev = std(GM);
    %ctrl = [ctrl;value];

 %   fprintf(fid,'%s %g %g\n', wpet_files, value, stdev); %%% value= mean grey matter 
%     C{1,i} = wpet_files{i};
%     C{2,i} = value;
%     C{3,i} = stdev;
%       P{1,i} = wpet_files{i};
%       P{2,i} = value;
%       P{3,i} = stdev;
%       MCS{1,i} = wpet_files{i};
%       MCS{2,i} = value;
%       MCS{3,i} = stdev;


%     %if(i==(nb_pet - 1))
%         meanctrl = mean(ctrl);
%         stdctrl = std(ctrl);
%         fprintf(fid,'statistic \t mean GM Value \t Stdev\n');
%         %fprintf(fid,'%s \t %g \t %g \n', 'Mean CTRl', meanctrl, stdctrl);
%         fprintf(fid,'%s \t %g \t %g \n', 'Mean CTRl', meanctrl, stdctrl);
%     %end

%status = fclose(fid);
% save([dirName '/Camille.mat'],'MCS');

%save basic data in a summary xls file
FileName=convertCharsToStrings(normImg);
MeanSUV=convertCharsToStrings(value);
SDSUV=convertCharsToStrings(stdev);
MeanSUV_HC=7.8818397;
SDSUV_HC=1.9006524;
Mean_Perc_vs_HC=convertCharsToStrings((value/7.8818397)*100);
SD_Perc_vs_HC=convertCharsToStrings((stdev/1.9006524)*100);
Mean_Dim_Perc_vs_HC=convertCharsToStrings(100-((value/7.8818397)*100));
SD_Dim_Perc_vs_HC=convertCharsToStrings(100-((stdev/1.9006524)*100));

SUV_info=table(FileName,MeanSUV,SDSUV,MeanSUV_HC,SDSUV_HC,Mean_Perc_vs_HC,SD_Perc_vs_HC,Mean_Dim_Perc_vs_HC,SD_Dim_Perc_vs_HC);

writetable(SUV_info,'SUV_info.xlsx');

filename=normImg;
ViewSUV3D(filename);

cd .. 
