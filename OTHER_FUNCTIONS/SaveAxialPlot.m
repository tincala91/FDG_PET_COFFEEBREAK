function SaveAxialPlot(template, hypo_nii, pres_nii)
% Saving an axial plot with a template, a hypo imagage and a preserved image
%
% Inputs
% images    
%
% Outputs
% None, only saving
%

close all
o = slover;

o.cbar = [];

o.img(1).vol = spm_vol(template);
o.img(1).type = 'truecolour';
o.img(1).cmap = gray;
[mx mn] = slover('volmaxmin',o.img.vol);
o.img(1).range = [mn mx];
o.img(1).prop=1;

o.img(2).vol = spm_vol (hypo_nii);
o.img(2).type = 'split';
o.img(2).range = [1.69 6];
o.img(2).cmap= winter;

o.img(3).vol = spm_vol (pres_nii);
o.img(3).type = 'split';
o.img(3).range = [1.69 6];
o.img(3).cmap= hot;

o.transform = 'axial';
o.cbar=(2:3);
o.figure = spm_figure('GetWin','Graphics');
o = fill_defaults (o);
o.slices = -42:4:78;

o = paint(o);

saveas(gcf,'Render_slover_multislice.jpg')
close all
return
