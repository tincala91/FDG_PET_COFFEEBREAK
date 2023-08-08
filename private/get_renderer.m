function params = get_renderer()
  global xSPM;

  params.XYZ = xSPM.XYZ;
  params.t = xSPM.Z;
  params.mat = xSPM.M;
  params.dim = xSPM.DIM;
end
