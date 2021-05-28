function percent_language()

%rex(SOURCES, ROIS, 'paramname1',paramvalue1,'paramname2',paramvalue2,...);
  %  permits the specification of additional parameters:
   %     'summary_measure' :     choice of summary measure (across voxels) [{'mean'},'eigenvariate','median','weighted mean','count']
    %    'level' :               summarize across [{'rois'},'clusters','peaks','voxels']
     %   'scaling' :             type of scaling (for timeseries extraction) [{'none'},'global','roi']
      %  'conjunction_mask':     filename of conjunction mask volume(s)
       % 'output_type' :         choice of saving output ['none',{'save'},'saverex']
        %'gui' :                 starts the gui [{0},1] 
        %'select_clusters'       asks user to select one or more clusters if multiple clusters exists within each ROI [0,{1}]
        %'dims' :                (for 'eigenvariate' summary measure only): number of eigenvariates to extract from the data
        %'mindist' :             (for 'peak' level only): minimum distance (mm) between peaks 
        %'maxpeak' :             (for 'peak' level only): maximum number of peaks per cluster
        
%declaring useful variables
global baseDir
dir_dicom=pwd; 
baseDirRender=fullfile(baseDir,'ROIs');     
           
        rex_source_hypo=fullfile(dir_dicom,'spmT_0001_Hypo.nii');
        rex_source_pres=fullfile(dir_dicom,'spmT_0002_Pres.nii');
        rex_source_mask=fullfile(dir_dicom,'mask.nii');
                
        rex_ROI1=fullfile(baseDirRender,'FRONTAL_L.img');
        rex_ROI2=fullfile(baseDirRender,'FRONTAL_R.img');
        rex_ROI3=fullfile(baseDirRender,'PARIETAL_L.img');
        rex_ROI4=fullfile(baseDirRender,'PARIETAL_R.img');
        rex_ROI5=fullfile(baseDirRender,'OCCIPITAL_L.img');
        rex_ROI6=fullfile(baseDirRender,'OCCIPITAL_R.img');
        rex_ROI7=fullfile(baseDirRender,'TEMPORAL_L.img');
        rex_ROI8=fullfile(baseDirRender,'TEMPORAL_R.img');
        rex_ROI9=fullfile(baseDirRender,'INSULA_L.img');
        rex_ROI10=fullfile(baseDirRender,'INSULA_R.img');
        rex_ROI11=fullfile(baseDirRender,'BASAL_GANGLIA.img');
        rex_ROI12=fullfile(baseDirRender,'THALAMUS.img');
        rex_ROI13=fullfile(baseDirRender,'BRAINSTEM.img');
        rex_ROI14=fullfile(baseDirRender,'CBL.img');
       
        
        rex_ROIs=char(rex_ROI1,rex_ROI2,rex_ROI3,rex_ROI4,rex_ROI5,rex_ROI6,rex_ROI7,rex_ROI8,rex_ROI9,rex_ROI10,rex_ROI11,rex_ROI12,rex_ROI13,rex_ROI14);
        
        
        Tot_voxels_hypo=rex(rex_source_hypo,rex_ROIs,'summary_measure','count','level','clusters','output_type','none','gui',0,'select_clusters',0);
        Tot_voxels_pres=rex(rex_source_pres,rex_ROIs,'summary_measure','count','level','clusters','output_type','none','gui',0,'select_clusters',0);
        Tot_voxels_ROI=rex(rex_source_mask,rex_ROIs,'summary_measure','count','level','clusters','output_type','none','gui',0,'select_clusters',0);
        
        Counts=[Tot_voxels_hypo;Tot_voxels_pres;Tot_voxels_ROI];
        Counts=Counts';
        
        ex_file=fullfile(baseDirRender,'percent_lobes.xlsx');
        copyfile(ex_file,dir_dicom);
        xlswrite('percent_lobes.xlsx',Counts,'B2:D15');

end
        