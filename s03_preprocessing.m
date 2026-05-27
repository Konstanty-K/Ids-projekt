% =========================================================================
% Identyfikacja Systemów Dynamicznych - Projekt HILSys
% Protokół S03: Wstępne przetwarzanie danych
% Autorzy: Konstanty Kaszubski, Oskar Jóźwik
% Wariant 02 (IV, GREY-BOX, Czas Ciągły)
% =========================================================================

clear all; close all; clc;

%% 1. Parametry podstawowe środowiska
Tp = 0.01; % Okres próbkowania podany w specyfikacji danych [s]

%% 2. Wczytanie danych z plików .mat
% Struktura plików zakłada obecność wektorów 'u' (wejście) i 'y' (wyjście)
disp('Wczytywanie danych pomiarowych...');
dataA = load('IdentDataA.mat');
dataB = load('IdentDataB.mat');
dataC = load('IdentDataC.mat');

% Deklaracja wektorów (wymuszenie wejścia na wektory kolumnowe dla spójności)
u_A = dataA.u(:); y_A = dataA.y(:);
u_B = dataB.u(:); y_B = dataB.y(:);
u_C = dataC.u(:); y_C = dataC.y(:);

% Długość próbek i tworzenie wektora czasu
N = length(y_A); 
t = (0:N-1)' * Tp;

%% 3. Odjęcie składowej stałej (punktu pracy)
% Zgodnie z protokołem wykorzystujemy początkowe próbki stanu ustalonego
N_steady = 150;

% Obliczanie średniej z początkowych stanów (punkt pracy)
y0_A = mean(y_A(1:N_steady)); u0_A = mean(u_A(1:N_steady));
y0_B = mean(y_B(1:N_steady)); u0_B = mean(u_B(1:N_steady));
y0_C = mean(y_C(1:N_steady)); u0_C = mean(u_C(1:N_steady));

% Przesunięcie sygnałów (centrowanie wokół zera)
u_A_proc = u_A - u0_A; y_A_proc = y_A - y0_A;
u_B_proc = u_B - u0_B; y_B_proc = y_B - y0_B;
u_C_proc = u_C - u0_C; y_C_proc = y_C - y0_C;

%% 4. Analiza wizualna i weryfikacja
figure('Name', 'S03: Przetwarzanie Danych - Zbiór A', 'NumberTitle', 'off', 'Position', [100 100 800 600]);

% Wykres wymuszenia (Sygnał u)
subplot(2,1,1);
plot(t, u_A, 'b--', 'LineWidth', 1); hold on;
plot(t, u_A_proc, 'b', 'LineWidth', 1.5);
xline(t(N_steady), 'k:', 'Koniec liczenia śr.');
title('Sygnał sterujący u(t) - Zbiór A');
xlabel('Czas [s]'); ylabel('Amplituda [V/jednostka]');
legend('Sygnał surowy', 'Po odjęciu punktu pracy', 'Location', 'best');
grid on;

% Wykres odpowiedzi (Sygnał y)
subplot(2,1,2);
plot(t, y_A, 'r--', 'LineWidth', 1); hold on;
plot(t, y_A_proc, 'r', 'LineWidth', 1.5);
xline(t(N_steady), 'k:', 'Koniec liczenia śr.');
title('Sygnał wyjściowy y(t) - Zbiór A');
xlabel('Czas [s]'); ylabel('Amplituda [jednostka]');
legend('Sygnał surowy', 'Po odjęciu punktu pracy', 'Location', 'best');
grid on;

%B
figure('Name', 'S03: Przetwarzanie Danych - Zbiór B', 'NumberTitle', 'off', 'Position', [100 100 800 600]);

% Wykres wymuszenia (Sygnał u)
subplot(2,1,1);
plot(t, u_B, 'b--', 'LineWidth', 1); hold on;
plot(t, u_B_proc, 'b', 'LineWidth', 1.5);
xline(t(N_steady), 'k:', 'Koniec liczenia śr.');
title('Sygnał sterujący u(t) - Zbiór B');
xlabel('Czas [s]'); ylabel('Amplituda [V/jednostka]');
legend('Sygnał surowy', 'Po odjęciu punktu pracy', 'Location', 'best');
grid on;

% Wykres odpowiedzi (Sygnał y)
subplot(2,1,2);
plot(t, y_B, 'r--', 'LineWidth', 1); hold on;
plot(t, y_B_proc, 'r', 'LineWidth', 1.5);
xline(t(N_steady), 'k:', 'Koniec liczenia śr.');
title('Sygnał wyjściowy y(t) - Zbiór B');
xlabel('Czas [s]'); ylabel('Amplituda [jednostka]');
legend('Sygnał surowy', 'Po odjęciu punktu pracy', 'Location', 'best');
grid on;

figure('Name', 'S03: Przetwarzanie Danych - Zbiór C', 'NumberTitle', 'off', 'Position', [100 100 800 600]);

% Wykres wymuszenia (Sygnał u)
subplot(2,1,1);
plot(t, u_C, 'b--', 'LineWidth', 1); hold on;
plot(t, u_C_proc, 'b', 'LineWidth', 1.5);
xline(t(N_steady), 'k:', 'Koniec liczenia śr.');
title('Sygnał sterujący u(t) - Zbiór C');
xlabel('Czas [s]'); ylabel('Amplituda [V/jednostka]');
legend('Sygnał surowy', 'Po odjęciu punktu pracy', 'Location', 'best');
grid on;

% Wykres odpowiedzi (Sygnał y)
subplot(2,1,2);
plot(t, y_C, 'r--', 'LineWidth', 1); hold on;
plot(t, y_C_proc, 'r', 'LineWidth', 1.5);
xline(t(N_steady), 'k:', 'Koniec liczenia śr.');
title('Sygnał wyjściowy y(t) - Zbiór C');
xlabel('Czas [s]'); ylabel('Amplituda [jednostka]');
legend('Sygnał surowy', 'Po odjęciu punktu pracy', 'Location', 'best');
grid on;
%% 5. Przypisanie do zbiorów: Estymacyjny (Ze) i Weryfikacyjne (Zv)
% Na podstawie protokołu rozdzielamy przetworzone serie
Ze.u = u_A_proc; Ze.y = y_A_proc; Ze.t = t;
Zv1.u = u_B_proc; Zv1.y = y_B_proc; Zv1.t = t;
Zv2.u = u_C_proc; Zv2.y = y_C_proc; Zv2.t = t;

disp('----------------------------------------------------');
disp('Przetwarzanie S03 zakończone sukcesem.');
disp('Punkt pracy usunięto z użyciem pierwszych 150 próbek.');
disp('Podział zbiorów:');
disp(' - Zbiór Estymacyjny (Ze)   : IdentDataA');
disp(' - Zbiór Weryfikacyjny (Zv1): IdentDataB');
disp(' - Zbiór Weryfikacyjny (Zv2): IdentDataC');
disp('----------------------------------------------------');