%---------------------------------------------------
%  plot voltage and current limits in i_dq plane
%---------------------------------------------------


%% inverter and motor limits
U_dc = 24; % DC link voltage in V
I_max = 160; % maximum currents in A
U_max = U_dc/sqrt(3); % maximum voltage in V


%% motor parameter fr. Kibo
Pp = 1;                                  % Polpaarzahl
Ls = 17.05e-6/3;                         % Induktivitaet
Rs = 10e-3*(1+0.0039*(120-20))/3;        % Wicklungswiderstand
Ts = Ls/Rs;                              % elektr. Zeitkonstante
Psi_p = 5.3e-3/sqrt(3)*0.95;            % Rotorflussverkettung

%% draw current limits
theta = 0:2*pi/1000:2*pi;
x_i = I_max*cos(theta);
y_i = I_max*sin(theta);
plot(x_i, y_i, 'r');
title('current limits');
xlabel('id/A');
ylabel('iq/A');
grid on;

%% draw voltage limits
n = 50000; % motor ratational speed in 1/min
omega_e = Pp*2*pi*n/60; % motor electric speed in rad/s
R_u = U_max/Ls/omega_e;
x_u = R_u*cos(theta)-Psi_p/Ls;
y_u = R_u*sin(theta);
hold on;
xlim([-1000 1000]);
ylim([-1000 1000]);
plot(x_u, y_u);