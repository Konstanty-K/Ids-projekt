% =========================================================================
% Identyfikacja Bezpośrednia IV - Obiekt 2. rzędu z zerem (Sztywno K=1)
% Struktura wymuszona: (b1*s + a0) / (s^2 + a1*s + a0)
% =========================================================================
clc; close all;

%% 1. Uruchomienie preprocessingu i pobranie danych
disp('Uruchamianie preprocessingu...');
run('s03_preprocessing.m'); 

% Pobranie danych ze zbioru estymacyjnego (Ze)
u = Ze.u;
y = Ze.y;
t = Ze.t;
N = length(y);

% t_start=5; %sekunda poczatku uzyteczanych danych
% N_poczatek = t_start/Tp; %ilosc probek do wyciecia
% u=u(N_poczatek:N);%dociete dane
% y=y(N_poczatek:N);
% t=t(N_poczatek:N); %dociety czas
% N=length(y)

%% 2. Definicja i aplikacja Filtrów Zmiennych Stanu (SVF)
s = tf('s');
TF = Tp * 12; % Stała czasowa filtru

% Definicja filtrów rzędu 2
F0 = 1 / (1 + s*TF)^2;      
F1 = s / (1 + s*TF)^2;      
F2 = s^2 / (1 + s*TF)^2;    

% Filtracja SVF sygnałów wejściowych i wyjściowych
uF   = lsim(F0, u, t, 'zoh');
upF  = lsim(F1, u, t, 'zoh'); 

yF   = lsim(F0, y, t, 'foh');
ypF  = lsim(F1, y, t, 'foh');
yppF = lsim(F2, y, t, 'foh');

%% 3. Wsadowa estymacja parametryczna metodą LS (Krok pomocniczy)
d = 3; % Zredukowana liczba parametrów: a1, a0, b1
Phi_LS = zeros(N, d);

for i = 1:N
    % Nowy regresor zgrupowany dla a0
    Phi_LS(i,:) = [-ypF(i), -(yF(i) - uF(i)), upF(i)];
end

phatLS = pinv(Phi_LS) * yppF;

% Model symulowany LS
% Kolejność w phatLS: (1)=a1, (2)=a0, (3)=b1
% Wymuszamy wyraz wolny w liczniku równy a0
GmLS = tf([phatLS(3), phatLS(2)], [1, phatLS(1), phatLS(2)]);

%% 4. Wsadowa estymacja parametryczna metodą IV (Krok docelowy)
% Generacja bezszumowego sygnału x z modelu LS
x = lsim(GmLS, u, t, 'zoh');

% Filtracja SVF sygnału x
xF  = lsim(F0, x, t, 'foh');
xpF = lsim(F1, x, t, 'foh');

Z_IV = zeros(N, d);
for i = 1:N
    % Instrumenty dla u pozostają takie same
    Z_IV(i,:) = [-xpF(i), -(xF(i) - uF(i)), upF(i)]; 
end

phatIV = pinv(Z_IV' * Phi_LS) * Z_IV' * yppF;

a1_est = phatIV(1);
a0_est = phatIV(2);
b1_est = phatIV(3);

% Ostateczny model ciągły IV z wymuszonym K=1
GmIV = tf([b1_est, a0_est], [1, a1_est, a0_est]);

%% 5. Przeliczenie na parametry fizyczne Grey-Box
% K = 1 (założenie)
% a0 = 1/T^2          => T = 1/sqrt(a0)
% a1 = 2*ksi/T        => ksi = a1*T/2
% b1 = Tz/T^2         => Tz = b1/a0

T_est   = 1 / sqrt(a0_est);
ksi_est = (a1_est * T_est) / 2;
Tz_est  = b1_est / a0_est;

disp('----------------------------------------------------');
fprintf('Odtworzone parametry fizyczne Grey-Box (Metoda IV, K=1):\n');
fprintf(' Stała czasowa T          = %f s\n', T_est);
fprintf(' Współczynnik tłumienia ksi = %f\n', ksi_est);
fprintf(' Stała czasowa zera Tz    = %f s\n', Tz_est);
disp('----------------------------------------------------');

%% 6. Weryfikacja JFIT na niezależnych zbiorach
y_sim_v1 = lsim(GmIV, Zv1.u, Zv1.t);
JFIT_v1 = (1 - norm(Zv1.y - y_sim_v1) / norm(Zv1.y - mean(Zv1.y))) * 100;

y_sim_v2 = lsim(GmIV, Zv2.u, Zv2.t);
JFIT_v2 = (1 - norm(Zv2.y - y_sim_v2) / norm(Zv2.y - mean(Zv2.y))) * 100;

y_sim_e = lsim(GmIV, Ze.u, Ze.t);
JFIT_e = (1 - norm(Ze.y - y_sim_e) / norm(Ze.y - mean(Ze.y))) * 100;

fprintf('Wskaźnik JFIT (Zv1 / Plik B): %.2f%%\n', JFIT_v1);
fprintf('Wskaźnik JFIT (Zv2 / Plik C): %.2f%%\n', JFIT_v2);
fprintf('Wskaźnik JFIT (Ze / Plik A): %.2f%%\n', JFIT_e);


%% 7. Wykresy weryfikacyjne
figure('Name', 'Weryfikacja modelu IV-SVF (K=1)', 'NumberTitle', 'off', 'Position', [150 150 1000 500]);

subplot(2,2,1);
plot(Zv1.t, Zv1.y, 'b', 'LineWidth', 1); hold on;
plot(Zv1.t, y_sim_v1, 'r--', 'LineWidth', 1.5);
title(sprintf('Weryfikacja Zv1 | JFIT = %.2f%%', JFIT_v1));
xlabel('Czas [s]'); ylabel('y'); legend('Pomiar', 'Model IV'); grid on;

subplot(2,2,2);
plot(Zv2.t, Zv2.y, 'b', 'LineWidth', 1); hold on;
plot(Zv2.t, y_sim_v2, 'r--', 'LineWidth', 1.5);
title(sprintf('Weryfikacja Zv2 | JFIT = %.2f%%', JFIT_v2));
xlabel('Czas [s]'); ylabel('y'); legend('Pomiar', 'Model IV'); grid on;

subplot(2,2,3);
plot(Ze.t, Ze.y, 'b', 'LineWidth', 1); hold on;
plot(Ze.t, y_sim_e, 'r--', 'LineWidth', 1.5);
title(sprintf('Weryfikacja Zv2 | JFIT = %.2f%%', JFIT_e));
xlabel('Czas [s]'); ylabel('y'); legend('Pomiar', 'Model IV'); grid on;