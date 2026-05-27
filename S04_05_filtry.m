% =========================================================================
% Identyfikacja Systemów Dynamicznych - Projekt HILSys
% Protokół S04-S05: Filtry Zmiennych Stanu (SVF) dla modelu II rzędu
% =========================================================================

% Zakładam, że w przestrzeni roboczej istnieją już struktury Ze, Zv1, Zv2 i zmienna Tp z etapu S03.
% Jeśli nie, należy najpierw uruchomić poprzedni skrypt.

%% 1. Przygotowanie folderu na wykresy
if ~exist('wykresy', 'dir')
    mkdir('wykresy');
end

%% 2. Projektowanie filtrów SVF II rzędu
% Transmitancja bazowa: F0(s) = lambda^2 / (s + lambda)^2
lambda = 10; % Parametr strojenia filtra [rad/s] - do ewentualnej poprawki
s = tf('s');

F0 = lambda^2 / (s + lambda)^2;   % Filtr dla sygnałów y_f oraz u_f
F1 = s * F0;                      % Filtr dla pierwszej pochodnej dy_f
F2 = s^2 * F0;                    % Filtr dla drugiej pochodnej ddy_f

disp(['Zaprojektowano filtry SVF II rzędu z lambda = ', num2str(lambda)]);

%% 3. Filtracja sygnałów dla zbioru estymacyjnego (Ze)
% lsim wymaga wektora czasu i wektora sygnału
disp('Filtrowanie sygnałów ze zbioru estymacyjnego...');

Ze.yf   = lsim(F0, Ze.y, Ze.t);
Ze.dyf  = lsim(F1, Ze.y, Ze.t);
Ze.ddyf = lsim(F2, Ze.y, Ze.t);
Ze.uf   = lsim(F0, Ze.u, Ze.t);

% Konstrukcja macierzy regresji (Phi) i wektora zmiennej objaśnianej (Y)
% Równanie: ddy_f(t) = -a1*dy_f(t) - a0*y_f(t) + b0*u_f(t)
Ze.Phi = [-Ze.dyf, -Ze.yf, Ze.uf];
Ze.Y   = Ze.ddyf;

%% 4. Wizualizacja wpływu filtracji SVF i zapis obrazka
fig_svf = figure('Name', 'S05: Filtracja SVF - Zbiór Estymacyjny', ...
                 'NumberTitle', 'off', 'Position', [150 150 900 700]);

% Sygnał u i u_f
subplot(3,1,1);
plot(Ze.t, Ze.u, 'Color', [0.7 0.7 0.7]); hold on;
plot(Ze.t, Ze.uf, 'b', 'LineWidth', 1.5);
title('Sygnał wejściowy u(t) oraz przefiltrowany u_f(t)');
ylabel('Amplituda'); legend('u(t)', 'u_f(t)'); grid on;

% Sygnał y i y_f
subplot(3,1,2);
plot(Ze.t, Ze.y, 'Color', [0.7 0.7 0.7]); hold on;
plot(Ze.t, Ze.yf, 'r', 'LineWidth', 1.5);
title('Sygnał wyjściowy y(t) oraz przefiltrowany y_f(t)');
ylabel('Amplituda'); legend('y(t)', 'y_f(t)'); grid on;

% Pochodne dy_f i ddy_f
subplot(3,1,3);
plot(Ze.t, Ze.dyf, 'g', 'LineWidth', 1.5); hold on;
plot(Ze.t, Ze.ddyf, 'm', 'LineWidth', 1.5);
title('Wygenerowane pochodne: pierwszej \dot{y}_f(t) i drugiej \ddot{y}_f(t)');
xlabel('Czas [s]'); ylabel('Amplituda'); 
legend('dy_f(t)', 'ddy_f(t)'); grid on;

% Zapis rysunku do pliku w wysokiej jakości
exportgraphics(fig_svf, fullfile('wykresy', 'S05_Filtracja_SVF.png'), 'Resolution', 300);
disp('Zapisano wykres do: wykresy/S05_Filtracja_SVF.png');

%% 5. (Opcjonalnie) Analogiczna filtracja dla zbiorów weryfikacyjnych (Zv1, Zv2)
% Będzie to potrzebne później do walidacji resztkowej na zbiorach weryfikacyjnych
Zv1.yf   = lsim(F0, Zv1.y, Zv1.t);
Zv1.dyf  = lsim(F1, Zv1.y, Zv1.t);
Zv1.ddyf = lsim(F2, Zv1.y, Zv1.t);
Zv1.uf   = lsim(F0, Zv1.u, Zv1.t);
Zv1.Phi  = [-Zv1.dyf, -Zv1.yf, Zv1.uf];
Zv1.Y    = Zv1.ddyf;

Zv2.yf   = lsim(F0, Zv2.y, Zv2.t);
Zv2.dyf  = lsim(F1, Zv2.y, Zv2.t);
Zv2.ddyf = lsim(F2, Zv2.y, Zv2.t);
Zv2.uf   = lsim(F0, Zv2.u, Zv2.t);
Zv2.Phi  = [-Zv2.dyf, -Zv2.yf, Zv2.uf];
Zv2.Y    = Zv2.ddyf;

disp('----------------------------------------------------');
disp('Krok S04-S05 zakończony. Macierze regresji Phi gotowe do estymacji.');
disp('----------------------------------------------------');