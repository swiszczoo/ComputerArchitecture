# Task 1
## Conversion to IEEE-754

Zaimplementuj algorytm konwersji liczby w kodzie U2 na liczbę zmiennoprzecinkową 4-bajtową
(`float`) w formacie IEEE 754 (opis formatu dostępny np. w). Zadbaj o prawidłową normalizację liczby `float`.

Nie używaj operacji zmiennoprzecinkowych (tylko operacje na liczbach całkowitych i logiczne). Nie używaj też w trakcie obliczeń **(!!!)** rejestrów zmiennoprzecinkowych.

Przyjmij że liczba do przekształcenia (32 bitowy `int`) znajduje się w zmiennej o nazwie `in_i` od obszarze zmiennych globalnych (`.data`). Wynik powinien być zapisany do zmiennej o nazwie `out_f` zlokalizowanej również w tym obszarze.

Do celów przetestowania przed zakończeniem programu wyprowadź wartość zmiennej `out_f` na
konsolę, jako wartość `float` za pomocą odpowiedniego wywołania systemowego. Do tego celu
możesz (a nawet musisz) użyć jednego rejestru zmiennoprzecinkowego.

**Which roughly translates to:**

Implement an algorithm that converts a Two's complement number to a 4-byte IEEE-754 floating point (`float`) number (format description available e.g. in *[I also don't know where :P]*). Take care for proper normalization of the `float` number.

Do not use any floating point operations (use only integer and logic instructions). Also, do not use any floating point registers **(!!!)** during calculation.

Assume that the number to convert (a 32-bit `int`) is located in a variable called `in_i` in the global variables section (`.data`). The result should be stored in the `out_f` variable, localized in the same section.

For testing purposes, print contents of the `out_f` variable to the console as a `float` value using a proper system call, before exiting the program. To do this, you may (or even must) use exactly one floating point register.

