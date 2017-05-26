%---------------------------------%
%   Initialized the simulation    %
%---------------------------------%
clear all;
%% Inverter parameter
f_sw = 28011; % inverter switching frequency in Hz
T_pwm =1/f_sw; % switching period in s
V_dc = 36; % DC link voltage in V
U_DC = V_dc; % TBD: delete this symble in model
I_max = 100; % peak value of maximum current

%% Simulation parameter (should be dimensioned after the inverter parameter)
T_sim = T_pwm/100; % simulation time step in s(fixed step solver)

%% Simulation configuration
Sel_Bench_Mode = 1; % 0->controlled speed; 1-> load torque
Sel_Bench_Spd = 0; % 1->constant; 0->speed ramp. Valid only when Sel_Bench_Mode is set to 0.
Sel_C_Slx_AVR = 1; %Select AVR implementation: 1->Slx; 0->C Code
Sel_id_ref = 2; % select the source of id_ref: 1->from AVR; 2-> constant 0 (no Fw)
Sel_Iq_ref = 1; % 1->from ASR; 0->from step/constant
Sel_FF_i = 1; % select the source of FF for SL controller: 1->i_ref; 0: i_act
sel_udq = 0; % 1-> Udq from SL; 0->Udq from C Code
en_avr = 0; % 1-> enable; 2-> disable
Sel_Load = 1; % 1-> eBooster load; 0-> constant load
C_Load = 0; % constant load in Nm
%% Motor and bench parameter
Rs = 10e-3*(1+0.0039*(120-20))/3; % stator resistance in ohm
Ls = 17.05e-6/3; % stator inductance in H
Pp = 1; % pole pair
Ts = Ls/Rs; % stator time constant
psi_p = 5.3e-3/sqrt(3)*0.95; % PM Rotor Flux in Vs
J_motor = (3.2220 + 11.438)*1e-6; % kgm^2
load_motor_target_spd = 70000*2*pi/60; % bench motor end speed in 1/s
load_motor_start_spd = 40000*2*pi/60; % in 1/s
spd_ramp_time = 0.05;% in s
load_motor_spd_ramp = (load_motor_target_spd - load_motor_start_spd)/spd_ramp_time; % speed ramp in speed controlled bench mode 1/s^2
Nset_const = 50000; % 1/min for constant speed set

T_LUT_row_ind = [5759.6, 6283.2, 6806.8, 7330.4];
T_LUT_col_ind = 0.03:0.005:0.11;
T_LUT_T = [0.1864, 0.1969, 0.2092, 0.2230, 0.2381, 0.2541, 0.2709, 0.2880, 0.3054, 0.3226, 0.3395, 0.3557, 0.3710, 0.3851, 0.3978, 0.4088, 0.4178;
           0.2089, 0.2214, 0.2360, 0.2522, 0.2699, 0.2886, 0.3080, 0.3279, 0.3479, 0.3677, 0.3870, 0.4054, 0.4226, 0.4384, 0.4524, 0.4642, 0.4736; 
		   0.2286, 0.2462, 0.2651, 0.2853, 0.3065, 0.3282, 0.3505, 0.3728, 0.3950, 0.4169, 0.4381, 0.4583, 0.4775, 0.4951, 0.5111, 0.5250, 0.5368; 
		   0.2489, 0.2760, 0.3020, 0.3271, 0.3513, 0.3748, 0.3977, 0.4200, 0.4418, 0.4633, 0.4845, 0.5056, 0.5266, 0.5477, 0.5689, 0.5903, 0.6121;
		  ];

%% Controller parameter
% speed controlller
Set_Speed_rpm = 50000; % speed reference in 1/min
Kpi_n = 0.0015;
Tni_n = Ts*1.5;
% current controller
Id_ref = 0; % in A
T_ctrl = T_pwm; % current controller time step
T_sigma = 1.5*T_ctrl;
Tni = Ts;
Kpi = 0.3;%Rs/2*Tni/T_sigma;
rate_i_rising = 100/0.02; %A/s
rate_i_falling = -100/0.02; %A/s
iq_set_step_time = 0.005; %s
iq_set_init_val = 15; %A
iq_set_fin_val = 100; %A

%% voltage controller
N_avr = 1;
Kpi_avr = sqrt(3)/20;% floating point
Tni_avr = Ts/5;
Id_ref_min = -1*160*0.8; % limited by permanent magnet and maximum current
Ke_imp = 1; % implementation factor for AVR controller error input
% speed controller

%% parameters currently not used
% Lw = 2/3*Ls;

% PLL
% T_pll = T_sim;
% PLL_fn  =  50;           % [Hz] closed-loop nominal frequency of PLL
% PLL_d   =  1;            % []    closed-loop damping factor of PLL
% PLL_Ki_Ta = (2*pi*PLL_fn)^2;    % [1/s^2] integral gain of PLL controller
% PLL_Kp = 2*PLL_d*2*pi*PLL_fn;   % [1/s] proportional gain of PLL controller

%% Controller parameter
% current measurement
curr_adc_gain = 0.6247; % [A]/digit

% constants in SW
FOC_CURR_NULLIFICATION = 511;
FOC_CURR_GAIN_SCU10 = 640; % 0.6247 * 1024 = 640
ONEDIVSQRT3_SCU16 = 37837; % 1/sqrt(3) << 16 = 37837.227;