function params = get_renderer(xSPM)

  params.XYZ = xSPM.XYZ;
  params.t = xSPM.Z;
  params.mat = xSPM.M;
  params.dim = xSPM.DIM;
end
