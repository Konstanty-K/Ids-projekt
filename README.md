# Identyfikacja Systemu HILSys (Wariant 02)

Projekt realizowany w ramach przedmiotu **Identyfikacja Systemów Dynamicznych** (Automatyka i Robotyka, Semestr VI) na Politechnice Poznańskiej. Prowadzący: dr hab. inż. Maciej Michałek.

## 👥 Zespół Projektowy
* Oskar Jóźwik
* Konstanty Kaszubski

## ⚙️ Środowisko i Narzędzia
* **Platforma:** MATLAB / Simulink
* **System operacyjny:** Środowisko rozwijane m.in. na systemie Ubuntu 24.04 (Linux)
* **Wersjonowanie:** Git / GitHub

## 🎯 Cel Projektu
Opracowanie precyzyjnego modelu dynamicznego dla nieliniowego systemu HILSys na podstawie danych wejścia-wyjścia zebranych eksperymentalnie. Docelowa jakość dopasowania symulatora w zbiorach weryfikacyjnych: **FIT ($J_{HT}$) > 95%**.

**Specyfikacja wylosowanego wariantu (02):**
* **Struktura modelu:** GREY-BOX
* **Metoda estymacji:** Metoda zmiennych instrumentalnych (IV - *Instrumental Variables*)
* **Charakter czasu:** Ciągły (Continuous-Time)

---

## 📝 Protokół Realizacji Badań (Checklista)

- [x] **S01:** Zapoznanie się z obiektem (A-priori). Wstępna ocena właściwości strukturalnych i sygnałowych.
- [x] **S02:** Przeprowadzenie eksperymentu informatycznego (pozyskanie danych ze środowiska laboratoryjnego).
- [ ] **S03:** Wstępne przetwarzanie danych.
  - [ ] Usunięcie składowej stałej (pierwsze 150 próbek).
  - [ ] Weryfikacja wizualna odszumiania/usunięcia punktu pracy.
  - [ ] Podział na zbiór estymacyjny ($Z_e$) i weryfikacyjne ($Z_{v1}$, $Z_{v2}$).
- [ ] **S04:** Projektowanie struktury modelu i filtru danych (Modelowanie GREY-BOX).
  - [ ] Wyprowadzenie równań fenomenologicznych z fizyki systemu.
  - [ ] Dobór pasma przenoszenia filtru SVF.
- [ ] **S05:** Obliczenie wektora/macierzy regresji oraz wektora zmiennej objaśnianej (filtracja sygnałów).
- [ ] **S06:** Przeprowadzenie procesu estymacji wybraną metodą (Metoda IV).
  - [ ] Wygenerowanie instrumentu (np. metoda pomocniczego modelu).
  - [ ] Wyznaczenie wektora parametrów.
- [ ] **S07:** Badanie strukturalne właściwości modelu.
  - [ ] Sprawdzenie stabilności modelu i rozmieszczenia pierwiastków.
  - [ ] Weryfikacja zysku statycznego (wzmocnienia).
- [ ] **S08:** Ocena i walidacja parametryczna.
  - [ ] Obliczenie błędów i wariancji wyestymowanych parametrów (jeśli dotyczy).
- [ ] **S09:** Walidacja resztkowa (Analiza błędów predykcji).
  - [ ] Autokorelacja błędu.
  - [ ] Korelacja wzajemna błędu i wejścia.
- [ ] **S10:** Walidacja symulacyjna.
  - [ ] Symulacja dla danych ze zbiorów $Z_{v1}$ i $Z_{v2}$.
  - [ ] Obliczenie wskaźnika FIT ($J_{HT}$).
- [ ] **S11:** Ocena końcowa, wnioski i ewentualny powrót do kroku S04.

---
*Dokumentacja opracowana zgodnie z wytycznymi i protokołem z laboratorium IdS.*
