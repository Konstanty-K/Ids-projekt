%% zapisanie regresji liniowej
clc;

% zapisanie modelu transmitancji oraz regresji liniowej układu
% wzór (19), (20)
% wyprowadzenie na kartce
% phi = [y(n-1) , u(n-1)] -- regresor
% p = [exp(-Tp/T), k*(1-exp(-Tp/T)] -- wektor parametrów zastępczych modelu

%% załadowanie danych
load 'IdentWsadowaDyn.mat'; % załadowanie pliku 

% dane + wykresy wstępne
k = 1;
T = 0.5;

Tp = 0.01;
N = 3001;
t = 0:Tp:(N-1)*Tp;

%y_c = DaneDynC(:, 2);
y_c = u_A_proc
%y_w = DaneDynW(:, 2);
u = DaneDynW(:, 1);

% figure
% plot(u, y_w)
% xlabel('u');
% ylabel('ywhite');
% title("wykres ywhite(u)")

figure
plot(u, y_c);
xlabel('u');
ylabel('ycolor');
title("wykres ycolor(u)")

figure
hold on
plot(t, y_w, color=[1,0,0, 1]);
plot(t, u, color=[0,1,0, 1]);
hold off;
xlabel('t');
ylabel('ywhite');
legend('ywhite', 'u');
title("wykres ywhite(t)")

figure
hold on
plot(t, y_c, color=[1,0,0, 1]);
plot(t, u, color=[0,1,0, 1]);
hold off;
xlabel('t');
ylabel('ycolor');
legend('ycolor', 'u');
title("wykres ycolor(t)")

% podział 50/50
N_split = 2000;

% Z est
u_est_w = DaneDynW(1:N_split, 1);
y_est_w = DaneDynW(1:N_split, 2);
y_est_c = DaneDynC(1:N_split, 2);
t_est = t(1:N_split);
% Z wer 
u_wer_w = DaneDynW(N_split+1:end, 1);
y_wer_w = DaneDynW(N_split+1:end, 2);
y_wer_c = DaneDynC(N_split+1:end, 2);
t_wer = t(N_split+1:end);

%% identyfikacja parametryczna oraz estymacja parametrów k i T
N_est = length(y_est_w);
Phi_white = zeros(N_est-1, 2); 
Phi_color = zeros(N_est-1, 2);

% zastosowanie wzorów 10, 11 i 12
for i=2:N_est
   Phi_white(i-1, :) = [y_est_w(i-1), u_est_w(i-1)];
   Phi_color(i-1, :) = [y_est_c(i-1), u_est_w(i-1)];
end
% obliczenie estymowanych parametrów wzór (12)
p_white = inv((Phi_white)'*Phi_white)*(Phi_white')*y_est_w(2:end);
p_color = inv(Phi_color'*Phi_color)*(Phi_color')*y_est_c(2:end);

% wyliczone estymaty parametrów modelu
T_white = -Tp/log(p_white(1));
k_white = p_white(2)/(1-p_white(1));
T_color = -Tp/log(p_color(1));
k_color = p_color(2)/(1-p_color(1));

%% weryfikacja otrzymanych parametrów (white)
% niezakłócona odpowiedź
Go = tf(k, [T 1]);
[yo, ~] = lsim(Go, u_wer_w', t_wer'); 

% predyktor jednokrokowy 
% y(n) = p1*y(n-1) + p2*u(n-1)
y_pred_white = p_white(1)*y_wer_w(1:end-1) + p_white(2)*u_wer_w(1:end-1);

% odpowiedź modelu symulowanego ym
num = [0, p_white(2)]; % licznik: p2 
den = [1, -p_white(1)]; % mianownik: z - p1
Gz_white = tf(num, den, Tp);
[ym_white, ~] = lsim(Gz_white, u_wer_w', t_wer');


figure
hold on
plot(t_wer, y_wer_w, 'b', 'MarkerSize', 1); % zmierzona odpowiedź systemu
plot(t_wer(2:end), y_pred_white, 'm'); % predyktor jednokrokowy
plot(t_wer, yo, 'c', 'LineWidth', 1);  % odpowiedź bez zakłóceń
plot(t_wer, ym_white, 'y', 'LineWidth', 1.5); % odpowiedź estymowanego modelu obiektu


xlabel('t');
ylabel('wyjście y');
legend('y zmierzone', 'y pred (1-krok)', 'yo niezakłócone', 'ym symulowane');
title('weryfikacja odpowiedzi na zbiorze Zwer dla szumu białego');
grid on;


%% weryfikacja otrzymanych parametrów (color)
% predyktor jednokrokowy
% y(n) = p1*y(n-1) + p2*u(n-1)
y_pred_color = p_color(1)*y_wer_c(1:end-1) + p_color(2)*u_wer_w(1:end-1);


% odpowiedź modelu symulowanego ym
num = [0, p_color(2)]; % licznik: p2 
den = [1, -p_color(1)]; % mianownik: z - p1
Gz_color = tf(num, den, Tp);
[ym_color, ~] = lsim(Gz_color, u_wer_w', t_wer');


figure
hold on
plot(t_wer, y_wer_c, 'b', 'MarkerSize', 1); % zmierzona odpowiedź systemu
plot(t_wer(2:end), y_pred_color, 'm'); % predyktor jednokrokowy
plot(t_wer, yo, 'c', 'LineWidth', 1);  % odpowiedź bez zakłóceń
plot(t_wer, ym_color, 'y', 'LineWidth', 1.5); % odpowiedź estymowanego modelu obiektu


xlabel('t');
ylabel('wyjście y');
legend('y zmierzone', 'y pred (1-krok)', 'yo niezakłócone', 'ym symulowane');
title('weryfikacja odpowiedzi na zbiorze Zwer dla szumu kolorowego');
grid on;

%% weryfikacja jakości, wzór (21)
Nv = N - N_est;

Vp_white = 0;
Vm_white = 0;

Vp_color = 0;
Vm_color = 0;

for i=1:Nv
    Vp_white = Vp_white + (y_wer_w(i) - p_white(1)*y_wer_w(i) + p_white(2)*u_wer_w(i))^2;
    Vp_color = Vp_color + (y_wer_c(i) - p_color(1)*y_wer_c(i) + p_color(2)*u_wer_w(i))^2;
end
Vp_white = Vp_white/Nv;
Vp_color = Vp_color/Nv;

for i=1:Nv
    Vm_white = Vm_white + (yo(i) - ym_white(i))^2;
    Vm_color = Vm_color + (yo(i) - ym_color(i))^2;
end
Vm_white = Vm_white/Nv;
Vm_color = Vm_color/Nv;

%% macierz kowiariancji oraz przedziały ufności dla zakłócenia białego
N_phi = size(Phi_white, 1); 
y_synchro = y_wer_w(end-N_phi+1 : end); 

d_p = length(p_white);
epsilon_w = y_synchro(:) - Phi_white * p_white; 

% estymata wariancji zakłócenia, wzór (15)
sigma2_w = (1 / (N_phi - d_p)) * sum(epsilon_w.^2);

% macierz kowariancji (wzór 14)
Cov_w = sigma2_w * inv(Phi_white' * Phi_white); 

% przedziały ufności (95% -> mnożnik 1.96 lub 2)
P_Nii = diag(Cov_w); 
margines = 1.96 * sqrt(P_Nii);

PU_dolny = p_white - margines;
PU_gorny = p_white + margines;

disp('Macierz kowariancji Cov[p_white]:');
disp(Cov_w);
disp('Przedziały ufności [Dolna, Górna]:');
disp([PU_dolny, PU_gorny]);

%% identyfikacja parametrów modelu czasu dyskretnego metodą IV
% utworzenie wektora zmiennych instrumentalnych na podstawie estymowanych
% parametrów modelu

[x, ~] = lsim(Gz_color, u_est_w', t_est');

Z = [x(1:end-1), u_est_w(1:end-1)];

p_iv = inv(Z'*Phi_color)*Z'*y_est_c(2:end);
T_iv = -Tp/log(p_iv(1));
k_iv = p_iv(2)/(1-p_iv(1));

%% weryfikacja otrzymanych parametrów (iv)
% predyktor jednokrokowy
% y(n) = p1*y(n-1) + p2*u(n-1)
y_pred_iv = p_iv(1)*y_wer_c(1:end-1) + p_iv(2)*u_wer_w(1:end-1);


% odpowiedź modelu symulowanego ym
num = [0, p_iv(2)]; % licznik: p2 
den = [1, -p_iv(1)]; % mianownik: z - p1
Gz_iv = tf(num, den, Tp);
[ym_iv, ~] = lsim(Gz_iv, u_wer_w', t_wer');


figure
hold on
plot(t_wer, y_wer_c, 'b', 'MarkerSize', 1); % zmierzona odpowiedź systemu
plot(t_wer(2:end), y_pred_iv, 'm'); % predyktor jednokrokowy
plot(t_wer, yo, 'c', 'LineWidth', 1);  % odpowiedź bez zakłóceń
plot(t_wer, ym_iv, 'y', 'LineWidth', 1.5); % odpowiedź estymowanego modelu obiektu


xlabel('t');
ylabel('wyjście y');
legend('y zmierzone', 'y pred (1-krok)', 'yo niezakłócone', 'ym symulowane');
title('weryfikacja odpowiedzi na zbiorze Zwer dla szumu kolorowego (LS+IV)');
grid on;

%% weryfikacja jakości, wzór (21)
Nv = N - N_est;

Vp_iv = 0;
Vm_iv = 0;

for i=1:Nv
    Vp_iv = Vp_iv + (y_wer_c(i) - p_iv(1)*y_wer_c(i) + p_iv(2)*u_wer_w(i))^2;
    Vm_iv = Vm_white + (yo(i) - ym_white(i))^2;
end

Vp_iv = Vp_iv/Nv;
Vm_iv = Vm_iv/Nv;
