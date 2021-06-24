function percent_regions()

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
        
global baseDir
global dir_dicom

%dir_dicom=pwd; 
baseDirRender=fullfile(baseDir,'ROIs');   
           
        rex_source_hypo=fullfile(dir_dicom,'spmT_0001_Hypo.nii');
        rex_source_pres=fullfile(dir_dicom,'spmT_0002_Pres.nii');
        rex_source_mask=fullfile(dir_dicom,'mask.nii');
        rex_ROIs=fullfile(baseDirRender,'aal_all_regions.img');
        
        Tot_voxels_hypo=rex(rex_source_hypo,rex_ROIs,'summary_measure','count','level','clusters','output_type','none','gui',0,'select_clusters',0);
        Tot_voxels_pres=rex(rex_source_pres,rex_ROIs,'summary_measure','count','level','clusters','output_type','none','gui',0,'select_clusters',0);
        Tot_voxels_ROI=rex(rex_source_mask,rex_ROIs,'summary_measure','count','level','clusters','output_type','none','gui',0,'select_clusters',0);
        
        Counts=[Tot_voxels_hypo;Tot_voxels_pres;Tot_voxels_ROI];
        Counts=Counts';
        
        ex_file=fullfile(baseDirRender,'percent_regions.xlsx');
        copyfile(ex_file,dir_dicom);
        xlswrite('percent_regions.xlsx',Counts,'C2:E120');

end
        