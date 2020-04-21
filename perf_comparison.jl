perf_table = DataFrame()

perf_table.TestDescription = [
    "Rollout, 1 ft (s)",
    "60 mph (s)",
    "100 mph (s)",
    "150 mph (s)",
    "Rolling start, 5-60 mph (s)",
    "Top gear, 30-50 mph (s)",
    "Top gear, 50-70 mph (s)",
    "¼-mile time (s)",
    "¼-mile speed (mph)"
]

perf_table.CarAndDriver = [
    0.2,
    2.4,
    6.0,
    15.2,
    2.9,
    1.1,
    1.6,
    10.5,
    130
]

u0 = [0.0, 0, 0.0];
tspan=(0, 20.0);

condition(u,t,integrator) = u[1] - 0.3048; #150 mph in m/s
affect!(integrator) = terminate!(integrator);
cb = ContinuousCallback(condition,affect!);
rollout = solve(ODEProblem(taycan_state, u0, tspan),Rodas4(autodiff=false), saveat=1e-3, reltol=1e-9, callback=cb);
ro_t = rollout.t[end]

condition(u,t,integrator) = u[2] - 67.056; #150 mph in m/s
affect!(integrator) = terminate!(integrator);
cb = ContinuousCallback(condition,affect!);
zeroTo150 = solve(ODEProblem(taycan_state, u0, tspan),Rodas4(autodiff=false), saveat=1e-3, reltol=1e-9, callback=cb);
zeroTo150.t[end]

z60_t = zeroTo60.t[end] - ro_t
t_150 = zeroTo150.t
x_150 = [zeroTo150.u[x][1] for x in 1:length(zeroTo150.t)]
v_150 = [zeroTo150.u[x][2] for x in 1:length(zeroTo150.t)]

z100_t=t_150[findfirst((x)->x>=44.704, v_150)] - ro_t
z150_t=zeroTo150.t[end]-ro_t

z5_t=t_150[findfirst((x)->x>=2.2352, v_150)]
five60_t = zeroTo60.t[end]-z5_t

z30_t=t_150[findfirst((x)->x>=13.4112, v_150)]
z50_t=t_150[findfirst((x)->x>=22.352, v_150)]
z70_t=t_150[findfirst((x)->x>=31.2928, v_150)]

thirty50_t = z50_t-z30_t
fifty70_t = z70_t - z50_t

q_mile_t = t_150[findfirst((x)->x>=402.336, x_150)] - ro_t
q_mile_v = v_150[findfirst((x)->x>=402.336, x_150)]*2.23694

perf_table.SimulationResults = [
    ro_t,
    z60_t,
    z100_t,
    z150_t,
    five60_t,
    thirty50_t,
    fifty70_t,
    q_mile_t,
    q_mile_v
]

perf_table.AbsoluteError = perf_table.SimulationResults- perf_table.CarAndDriver
perf_table.RelativeError = (perf_table.AbsoluteError./perf_table.CarAndDriver)*100
