function K_Create_Report(dir_path, sub_info)


% Script Usage: Create a Report 
%
%

global TEMPLATE_DIR

data.SUVdecrease = int2str(round(sub_info.meandim))
%data.SUVdecrease = '48'
data.SUVimage = img2rtf(fullfile(dir_path, 'SUV',  strcat('wSUV_', sub_info.code, '.png')));
data.hypoimage = img2rtf(fullfile (dir_path,'SPM', 'Render_hypo_old.jpg'));
data.preservedimage = img2rtf(fullfile(dir_path, 'SPM', 'Render_pres_old.jpg'));

in = fullfile(TEMPLATE_DIR, '06_Template_PET_Report_neu.rtf');
out = fullfile(dir_path, 'SPM', 'PET_Report.rtf');

replace_in_file(in, out, data);
