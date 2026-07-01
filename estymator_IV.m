% =========================================================================
% Identyfikacja Bezpośrednia IV (Czas Ciągły)
% Wymaga wcześniejszego wykonania skryptu s03_preprocessing.m
% =========================================================================
clc; close all;

%% 1. Uruchomienie preprocessingu i pobranie danych
% Skrypt załaduje struktury: Ze (A), Zv1 (B), Zv2 (C)
disp('Uruchamianie preprocessingu...');
run('s03_preprocessing.m'); 

% Pobranie danych ze zbioru estymacyjnego (Ze)
y_est = Ze.y;
u_est = Ze.u;
t_est = Ze.t;

N = length(y);
t_start=5; %sekunda poczatku uzyteczanych danych
N_poczatek = t_start/Tp; %ilosc probek do wyciecia
u=u_A_proc(N_poczatek:N);%dociete dane
y=y(N_poczatek:N);
t=t(N_poczatek:N); %dociety czas

%% 2. Aproksymacja pochodnej dla czasu ciągłego
% Używamy różnicy wstecznej dla zbioru estymacyjnego
dy_est = zeros(length(y_est), 1);
dy_est(2:end) = (y_est(2:end) - y_est(1:end-1)) / Tp;

% Obcięcie pierwszych próbek (ze względu na błąd aproksymacji dla t=0)
dy_est_k = dy_est(2:end);
y_est_k  = y_est(2:end);
u_est_k  = u_est(2:end);
t_est_k  = t_est(2:end);

%% 3. Krok I: Estymator pomocniczy LS (Najmniejszych Kwadratów)
% Model wyjściowy: dy/dt = -a1*y + b0*u
Phi_LS = [-y_est_k, u_est_k];

% Estymacja LS (użycie operatora '\' dla stabilności numerycznej)
theta_LS = (Phi_LS' * Phi_LS) \ (Phi_LS' * dy_est_k);
a1_ls = theta_LS(1);
b0_ls = theta_LS(2);

% Budowa modelu pomocniczego
sys_LS = tf(b0_ls, [1, a1_ls]);

%% 4. Krok II: Generowanie zmiennych instrumentalnych (IV)
% Symulacja modelem pomocniczym (odpowiedź y_hat pozbawiona szumu)
y_hat_est = lsim(sys_LS, u_est_k, t_est_k);

% Konstrukcja macierzy instrumentów Z
Z_IV = [-y_hat_est, u_est_k];

%% 5. Krok III: Estymacja docelowa metodą IV
% Równanie estymatora zmiennych instrumentalnych
theta_IV = (Z_IV' * Phi_LS) \ (Z_IV' * dy_est_k);
a1_iv = theta_IV(1);
b0_iv = theta_IV(2);

% Ostateczny model ciągły
sys_IV = tf(b0_iv, [1, a1_iv]);

disp('----------------------------------------------------');
fprintf('Wyniki Estymacji Bezpośredniej IV:\n');
fprintf(' a1 = %f\n', a1_iv);
fprintf(' b0 = %f\n', b0_iv);
fprintf(' Zastępcza stała czasowa T = %f s\n', 1/a1_iv);
fprintf(' Zastępcze wzmocnienie k = %f\n', b0_iv/a1_iv);
disp('----------------------------------------------------');

%% 6. Weryfikacja modeli (JFIT) na niezależnych zbiorach
% --- Zbiór Zv1 (Plik B) ---
y_sim_v1 = lsim(sys_IV, Zv1.u, Zv1.t);
JFIT_v1 = (1 - norm(Zv1.y - y_sim_v1) / norm(Zv1.y - mean(Zv1.y))) * 100;
fprintf('Wskaźnik JFIT dla weryfikacji Zv1 (B): %.2f%%\n', JFIT_v1);

% --- Zbiór Zv2 (Plik C) ---
y_sim_v2 = lsim(sys_IV, Zv2.u, Zv2.t);
JFIT_v2 = (1 - norm(Zv2.y - y_sim_v2) / norm(Zv2.y - mean(Zv2.y))) * 100;
fprintf('Wskaźnik JFIT dla weryfikacji Zv2 (C): %.2f%%\n', JFIT_v2);

%% 7. Wykresy weryfikacyjne
figure('Name', 'Weryfikacja modelu IV na zbiorach niezależnych', 'NumberTitle', 'off', 'Position', [150 150 1000 500]);

% Wykres dla Zv1
subplot(1,2,1);
plot(Zv1.t, Zv1.y, 'b', 'LineWidth', 1); hold on;
plot(Zv1.t, y_sim_v1, 'r--', 'LineWidth', 1.5);
title(sprintf('Weryfikacja Zv1 (Plik B) | JFIT = %.2f%%', JFIT_v1));
xlabel('Czas [s]'); ylabel('Amplituda [y]');
legend('Sygnał zmierzony', 'Odpowiedź modelu IV');
grid on;

% Wykres dla Zv2
subplot(1,2,2);
plot(Zv2.t, Zv2.y, 'b', 'LineWidth', 1); hold on;
plot(Zv2.t, y_sim_v2, 'r--', 'LineWidth', 1.5);
title(sprintf('Weryfikacja Zv2 (Plik C) | JFIT = %.2f%%', JFIT_v2));
xlabel('Czas [s]'); ylabel('Amplituda [y]');
legend('Sygnał zmierzony', 'Odpowiedź modelu IV');
grid on;