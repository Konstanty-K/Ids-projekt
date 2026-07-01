% =========================================================================
% Analiza Wstępna (Czasowa i Widmowa) wg instrukcji dr hab. M. Szymkowiak
% Automatyczny zapis wykresów (wersja standardowa)
% =========================================================================
clc; close all;

%% 1. Uruchomienie preprocessingu i pobranie danych
disp('Uruchamianie preprocessingu do analizy...');
run('s03_preprocessing.m'); 

u = Ze.u;
y = Ze.y;
Fs = 1 / Tp;

disp('Generowanie i zapisywanie wykresów...');

%% 2. Analiza Statystyczna (Histogramy)
fig1 = figure('Name', 'Analiza Statystyczna', 'NumberTitle', 'off', 'Position', [100, 100, 800, 400]);

subplot(1,2,1);
hist(u, 50);
title('Histogram sygnału sterującego u');
xlabel('Amplituda'); ylabel('Liczebność');
grid on;

subplot(1,2,2);
hist(y, 50);
title('Histogram sygnału wyjściowego y');
xlabel('Amplituda'); ylabel('Liczebność');
grid on;

% Eksport do pliku
exportgraphics(fig1, 'histogramy.jpeg', 'Resolution', 300);
disp(' - Zapisano: histogramy.jpeg');

%% 3. Analiza Czasowa (Funkcje korelacji)
[Ruu, tau_u]  = xcorr(u, 'unbiased');
[Ryu, tau_yu] = xcorr(y, u, 'unbiased');

fig2 = figure('Name', 'Analiza Korelacyjna', 'NumberTitle', 'off', 'Position', [150, 150, 800, 600]);

subplot(2,1,1);
plot(tau_u * Tp, Ruu, 'b');
title('Autokorelacja wymuszenia R_{uu}(\tau)');
xlabel('\tau [s]'); ylabel('Amplituda');
xlim([-5 5]); grid on;

subplot(2,1,2);
plot(tau_yu * Tp, Ryu, 'r');
title('Korelacja wzajemna R_{yu}(\tau)');
xlabel('\tau [s]'); ylabel('Amplituda');
xlim([-2 10]); grid on;

% Eksport do pliku
exportgraphics(fig2, 'korelacje.jpeg', 'Resolution', 300);
disp(' - Zapisano: korelacje.jpeg');

%% 4. Analiza Widmowa (Gęstość widmowa mocy)
[Puu, fu] = pwelch(u, [], [], [], Fs);
[Pyy, fy] = pwelch(y, [], [], [], Fs);

fig3 = figure('Name', 'Widmowa Gęstość Mocy', 'NumberTitle', 'off', 'Position', [200, 200, 800, 600]);

subplot(2,1,1);
plot(fu, 10*log10(Puu), 'b');
title('Gęstość widmowa mocy sygnału u (PSD)');
xlabel('f [Hz]'); ylabel('PSD [dB/Hz]');
grid on;

subplot(2,1,2);
plot(fy, 10*log10(Pyy), 'r');
title('Gęstość widmowa mocy sygnału y (PSD)');
xlabel('f [Hz]'); ylabel('PSD [dB/Hz]');
grid on;

% Eksport do pliku
exportgraphics(fig3, 'psd.jpeg', 'Resolution', 300);
disp(' - Zapisano: psd.jpeg');

%% 5. Estymacja Nieparametryczna w Dziedzinie Częstotliwości
data = iddata(y, u, Tp);
Getfe = etfe(data);
Gspa = spa(data);

fig4 = figure('Name', 'Estymaty Nieparametryczne (Bode)', 'NumberTitle', 'off', 'Position', [250, 250, 800, 600]);

bode(Getfe, 'b', Gspa, 'r', {0.1, pi/Tp});
legend('ETFE (Empiryczna)', 'SPA (Widmowa)', 'Location', 'southwest');
grid on;
title('Charakterystyka amplitudowo-fazowa systemu HILSys');

% Eksport do pliku
exportgraphics(fig4, 'bode_nieparametryczna.jpeg', 'Resolution', 300);
disp(' - Zapisano: bode_nieparametryczna.jpeg');

disp('----------------------------------------------------');
disp('Zakończono analizę i eksport grafiki.');
disp('Wszystkie pliki .jpeg są gotowe do użycia w Quarto.');