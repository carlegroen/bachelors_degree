clc
close all
clear all
format long g
%-----------------------Definitions:---------------------------------------

%Rocket information. All units in: [kg, kJ, kPa, Kelvin, degrees, mol]
%Defining: Chamber volume, ambient pressure, ambient temperature, 
%oxidizer purity percentage, oxidizer used, oxidizer mass flow, oxidizer mass, 
%gas constant, chamber area, throat area, calculation timesteps, counter
%enthalpy for: water, O2, CO2, Stefan-Boltzman constant, Avogadros number
%injection duration,
V_chamber   = 3;                %[L]
P_amb       = 101.3;            %[kPa]
T_amb       = 273.15 + 20;      %[K]
x_oxidizer  = 0.8;              %fraction
f           = 0.59;             %fraction
m_dot_oxidizer = 0.273;         %[kg/s]
mass_H2O2   = 1.3 * x_oxidizer; %[kg]
mass_H2O    = 1.3 - mass_H2O2;  %[kg]
R           = 8.3145;           %[kJ/(mol*K)]
A_chamber   = (0.094)^2;        %[m]^2
A_throat    = (0.0213)^2;       %[m]^2
dt          = 0.01;             %[s]
k           = 2;                %[s]
H_water     = 83.93;            %[kJ/kg]
H_oxygen    = -4.887;           %[kJ/kg]
H_CO2       = -5.168;           %[kJ/kg]
kB          = 1.38065E-23;      %[J/K]
NA          = 6.02214086E23;    %[mol]^-1
time_state1 = (mass_H2O2+mass_H2O)/m_dot_oxidizer; %[s]

%Defining: H2O2, H2O, O2, Plastic grain, CO2 Molar masses:
M_H2O2 = 0.0340147; %[kg/mol]
M_H2O  = 0.0180153; %[kg/mol]
M_O2   = 0.0319988; %[kg/mol]
M_PLA  = 0.0720000; %[kg/mol]
M_CO2  = 0.0440095; %[kg/mol]

%Defining specific enthalpy from decomposition and combustion reaction:
%2*H2O2 -> 2*H2O + O2 and C3H4O2 + 3*O2 -> 3*CO2 + 2*H2O respectively
H2O2_Gibbs_free      = 98.2;                   %[kJ/mol]
DELTAh_decomposition = H2O2_Gibbs_free/M_H2O2; %[kJ/kg]
DELTAh_combustion    = 18000;                  %[kJ/kg]

% ---------------------- Flow rates ---------------------------------------

%-----------------------State 1: Injection:--------------------------------
%Injection starts at t=0
n_H2O2_1    = mass_H2O2/M_H2O2;                    %[mol]
n_H2O_1     = mass_H2O/M_H2O;                      %[mol]
n_O2_1      = 0;
n_CO2_1     = 0;

n_dot_H2O2_1 = x_oxidizer*m_dot_oxidizer/M_H2O2;
n_dot_H2O_1  = (1-x_oxidizer)*m_dot_oxidizer/M_H2O;
n_dot_O2_1   = 0;
n_dot_CO2_1  = 0;


n_flow_1    = n_H2O2_1 + n_H2O_1;                         %Total flow from injection
M_1         = (n_H2O_1*M_H2O + n_H2O2_1*M_H2O2)/n_flow_1; %mass of injected matter
m_1         = (n_H2O_1*M_H2O + n_H2O2_1*M_H2O2);

%-----------------------State 2: Decomposition:----------------------------
%Decomposition starts one time step dt later:

n_H2O2_2 = 0;                   %[mol]
n_H2O_2  = n_H2O_1 +  n_H2O2_1; %[mol]
n_O2_2   = 0.5 * n_H2O2_1;      %[mol]
n_CO2_2  = 0;                   %[mol]

n_dot_H2O2_2 = 0;
n_dot_H2O_2  = n_dot_H2O_1 + n_dot_H2O2_1;
n_dot_O2_2   = 0.5*n_dot_H2O2_1;
n_dot_CO2_2  = 0;

n_flow_2 = n_H2O2_2 + n_H2O_2 + n_O2_2;     %[mol]
m_2      = n_H2O_2 * M_H2O + n_O2_2 * M_O2; %[kg]

%-----------------------State 3: Combustion:-------------------------------
% starts one time step dt later yet:

n_H2O2_3 = 0;
n_H2O_3  = n_H2O_2 +  f*2/3*n_O2_2; %[mol]
n_O2_3   = (1-f)*n_O2_2;
n_CO2_3  = f*n_O2_2;

n_dot_H2O2_3 = 0;
n_dot_H2O_3  = n_dot_H2O_2 + f * 2/3 * n_dot_O2_2;
n_dot_O2_3   = (1-f)*n_dot_O2_2;
n_dot_CO2_3  = f*n_dot_O2_2;

n_flow_3 = n_H2O2_3 + n_H2O_3 + n_O2_3 +n_CO2_3;
m_PLA_3  = n_CO2_3/3*M_PLA;
m_dot_PLA_3  = n_dot_CO2_3/3*M_PLA;
m_3      = n_H2O_3 * M_H2O + n_O2_3 * M_O2 + n_CO2_3 * M_CO2;
M_3      = m_3/n_flow_3;



% ---------------------- Total Flow rates ---------------------------------

n_dot_H2O  = [n_dot_H2O_1 n_dot_H2O_2 n_dot_H2O_3];
n_dot_H2O2 = [n_dot_H2O2_1 n_dot_H2O2_2 n_dot_H2O2_3];
n_dot_O2   = [n_dot_O2_1 n_dot_O2_2 n_dot_O2_3];
n_dot_CO2  = [n_dot_CO2_1 n_dot_CO2_2 n_dot_CO2_3];

n_dot_1    = n_dot_H2O2_1 + n_dot_H2O_1 + n_dot_O2_1 + n_dot_CO2_1;
n_dot_2    = n_dot_H2O2_2 + n_dot_H2O_2 + n_dot_O2_2 + n_dot_CO2_2;
n_dot_3    = n_dot_H2O2_3 + n_dot_H2O_3 + n_dot_O2_3 + n_dot_CO2_3;
n_dot_tot        = [n_flow_1 n_flow_2 n_flow_3]*dt;

%Checking that mass is conserved in two first states
mass_conservation = [m_1 m_2 m_3];

%------------Reference enthalpy for further calculations:------------------
H_ref(1) = n_dot_H2O_1 * M_H2O * H_water + n_dot_O2_1 * M_O2 * H_oxygen + n_dot_CO2_1 * M_CO2 * H_CO2;
H_ref(2) = n_dot_H2O_2 * M_H2O * H_water + n_dot_O2_2 * M_O2 * H_oxygen + n_dot_CO2_2 * M_CO2 * H_CO2;
H_ref(3) = n_dot_H2O_3 * M_H2O * H_water + n_dot_O2_3 * M_O2 * H_oxygen + n_dot_CO2_3 * M_CO2 * H_CO2;

for z=1:3
    H_dot_ref(z) = n_dot_H2O(z) * M_H2O * H_water + n_dot_O2(z) * M_O2 * H_oxygen + n_dot_CO2(z) * M_CO2 * H_CO2;
end
H_comparison = H_dot_ref

%------------Total temperature and enthalpy for real states:---------------
H_real(1) = H_ref(1);
H_real(2) = H_ref(2) + DELTAh_decomposition*n_dot_H2O2_1*M_H2O2;
H_real(3) = H_ref(3) + DELTAh_decomposition*n_dot_H2O2_1*M_H2O2 + DELTAh_combustion*m_dot_PLA_3;
H_dot_real = H_real*dt;


T_H2O_1 = (2/3 *(n_dot_H2O_1 * M_H2O * H_water + 1100*V_chamber)/kB)/(n_dot_H2O_1*NA);
T_H2O_2 = (2/3 *(n_dot_H2O_2 * M_H2O * H_water + 1100*V_chamber)/kB)/(n_dot_H2O_2*NA);
T_H2O_3 = (2/3 *(n_dot_H2O_3 * M_H2O * H_water + 1100*V_chamber)/kB)/(n_dot_H2O_3*NA);

T_O2_2 = (2/3 *(n_dot_O2_2 * M_O2 * H_oxygen + 1100*V_chamber)/kB)/(n_dot_O2_2*NA);
T_O2_3 = (2/3 *(n_dot_O2_3 * M_O2 * H_oxygen + 1100)/kB)/(n_dot_O2_3*NA);

T_CO2_2 = (2/3 *(n_dot_CO2_3 * M_CO2 * H_CO2 + 1100*V_chamber)/kB)/(n_dot_CO2_3*NA);
T_CO2_3 = (2/3 *(n_dot_CO2_3 * M_CO2 * H_CO2 + 1100*V_chamber)/kB)/(n_dot_CO2_3*NA);

T_s2 = T_H2O_2+T_O2_2+T_CO2_2
T_s3 = T_O2_3+T_CO2_3


%Create pressure array
P_tot = [];
T     = [];
H     = [];
v_outflow = [];

%Assign setting at t=dt, just after injection
P_tot(1) = P_amb;
dP = n_dot_1*dt * T_amb * R/V_chamber;
P_tot(2) = P_amb + dP;
T(1)     = T_amb

%assign setting at t=2dt, after first decomposition
dP =(n_dot_2+n_dot_1)*dt * T_amb * R/V_chamber;
P_tot(3) = P_tot(1) + dP;
T(2) = T_amb + 2/3 * (H_dot_real(1)*dt+dP*V_chamber)/(kB*n_flow_1*dt*NA);
T(3) = T_amb;
T2(2) = T_amb;
T3(3) = T_amb;

density   = (mass_H2O2+mass_H2O)/V_chamber;
v_outflow(2) = sqrt(2*(P_tot(2)-P_amb)/density);
v_outflow(3) = sqrt(2*(P_tot(3)-P_amb)/density);
P = P_amb;
gamma =1.197;

dpP = n_dot_tot(1) * T_amb * R/V_chamber;
T_2 = T_amb + 2/3 * ((H_dot_real(1)+H_dot_real(2))+1100*V_chamber)/(kB*(n_dot_tot(1)+n_dot_tot(2))*NA);

for t=2*dt:dt:time_state1/dt
         m_dot_out = 1;
         n_out     = (n_dot_1+n_dot_2+n_dot_3)*dt*0.75;
         n_in      = (n_dot_1+n_dot_2+n_dot_3)*dt;
         n_delta   = n_in - n_out;
         k         = k + 1;
         T(k)      = T(k-1) + 2/3 * 1/(kB*n_delta*NA) * 
         %T(k)      = T(k-1) + 2/3 * ((sum(H_dot_real))*dt+dP*V_chamber)/(kB*n_delta*NA);
         dP        = n_delta * T(k-1) * R/V_chamber;
         P_tot(k)  = P_tot(k-1) + dP;
         %T(k)      = T(k-1) + 2/3 * ((sum(H_dot_real))*dt+dP*V_chamber)/(kB*(n_dot_1+n_dot_2+n_dot_3)*dt*NA);
         P_outflow(k) = P_tot(k-1) + n_in * T(k-1) * R/V_chamber;
         
         v_outflow(k) = sqrt(2*(P_outflow(k)-P_amb)/density);
end

v_out = sqrt(2*(P_tot-P_amb)/density);


% ---------------------- Plotting Process ---------------------------------
%Timesteps for process.
tspan = (0:dt:time_state1/dt);

%Lines at specified ranges
kbarlinex = [0 5];
kbarliney = [1000 1000];
kelvbarliney = [101.3 1000];
kelvbarlinex = [273.15 2000];

%Approximate velocity-cap
T_test    = 1920;

m_dot_H2O_3 = n_dot_H2O_3 * M_H2O
m_dot_O2_3  = n_dot_O2_3 * M_O2
m_dot_CO2_3 = n_dot_O2_3 * M_CO2
M_dot_3     = (m_dot_H2O_3 + m_dot_O2_3 + m_dot_CO2_3)/n_dot_3

max_v     = sqrt(T_test*R/(M_dot_3)*2*gamma/(gamma-1)*(1-(P_amb./P_tot).^((gamma-1)/gamma)));

figure(1)
    title('Pressure per time simulation of injection')
        
    subplot(2,2,1);
        plot(tspan,P_tot,'-o')
        hold on
        plot(kbarlinex,kbarliney,'-')
        hold on
        plot(tspan,P_outflow,'-o')
        axis([0 .2 0 5000])
        xlabel('time [s]')
        ylabel('Pressure [kPa]')
        legend('Pressure in chamber','Working pressure','Pressure without mass outflow')
    
    subplot(2,2,2)
        plot(tspan,v_out)
        hold on
        plot(tspan,max_v)
        hold on
        plot(tspan,v_outflow)
        axis([0 1 0 4000])
        xlabel('time [s]')
        ylabel('Velocity [m/s]')
        legend('Velocity based on stagnation pressure','Maximum attainable velocity','Velocity with chamber outflow')
        
% figure(2)
     subplot(2,2,3)       
        plot(kelvbarlinex,kelvbarliney,'-')
        hold on
        plot(T(1:10),P_tot(1:10))
        hold on
        axis([T_amb 3500 P_amb 1500])
        xlabel('Temperature [K]')
        ylabel('Pressure [kPa]')
        legend('Temperature in stagnated chamber')