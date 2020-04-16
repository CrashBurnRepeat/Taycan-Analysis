# Load data
pt_max_tq = readdlm(
    "taycan_pt_tq.txt",
    ',',
    Float64,
    '\n',
    skipstart=1);

ra1_max_tq = readdlm(
    "taycan_pt_tq_ra1.txt",
    ',',
    Float64,
    '\n',
    skipstart=1)
ra1_max_tq[1,1]=0.0;

ra2_max_tq = readdlm(
    "taycan_pt_tq_ra2.txt",
    ',',
    Float64,
    '\n',
    skipstart=1);

fa_max_tq = readdlm(
    "taycan_pt_tq_fa.txt",
    ',',
    Float64,
    '\n',
    skipstart=1);

#Fit data into interpolation objects
max_tq_itp = LinearInterpolation(
    pt_max_tq[:,1],
    pt_max_tq[:,2],
    extrapolation_bc=Line()
);

ra1_max_itp = LinearInterpolation(
    ra1_max_tq[:,1],
    ra1_max_tq[:,2],
    extrapolation_bc = Line()
);

ra2_max_itp = LinearInterpolation(
    ra2_max_tq[:,1],
    ra2_max_tq[:,2],
    extrapolation_bc = Line()
);

fa_max_itp = LinearInterpolation(
    fa_max_tq[:,1],
    fa_max_tq[:,2],
    extrapolation_bc = Flat()
);

#Create total and boosted torque
ra_max_itp(spd) = max(ra1_max_itp(spd), ra2_max_itp(spd))
boosted_ra_max_itp(spd) = min(ra_max_itp(spd)*370/335, 610*15.33)
pwr_idx = findfirst(x->x<3100, fa_max_tq[:,2]);
pwr_poly = fit(Poly, fa_max_tq[pwr_idx:end,1], fa_max_tq[pwr_idx:end,2],4);
boosted_fa_max_itp(spd) = min(440*8.05, pwr_poly(spd));

#Create pt force functions
boosted_pt_f(v) =
    boosted_fa_max_itp(3.6*v*slip_ratio)/tire_r_front +
    boosted_ra_max_itp(3.6*v*slip_ratio)/tire_r_rear

max_pt_f(v) = max_tq_itp(3.6*v*slip_ratio)/((tire_r_front+tire_r_rear)/2)
