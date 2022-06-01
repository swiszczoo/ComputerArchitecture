# Task 4
# String functions

Zaimplementuj zestaw funkcji do przetwarzania napisów. Przyjmij, że napisy wykorzystują kodowanie ASCII (jeden znak na jednym bajcie). Przyjmij konwencję jak w języku C/C++ gdzie znakiem końca napisu jest bajt `0x00`. Przyjmij, że argumenty funkcji przekazywane są w rejestrach `$a0`, `$a1` itd. Wartość zwracana (jeśli jest) przekazywana jest w rejestrze `$v0`.

Zaimplementuj następujące funkcje

```c
int strlen( char *string );
   // wyznacza liczbę znaków w napisie - bez znaku końca napisu
int strcmp( char *sring1, char *string2);
   // porównuje napisy leksykograficznie (alfabetycznie) zwraca:
   // -1 - jeśłi napis string1 poprzedza napis string2
   // 0 - jeśli napisy są sobie równe
   // 1 - jeśli string2 poprzedza string1
void strcat( char *dest, char *string1, char *string2 );
   // łączy napisy string1 i string2, umieszcza wynikowy napis
   // pod adresem dest
int strfind( char *string, char *fragment );
   // znajduje indeks pierwszego znaku wystąpienia napisu fragment
   // w napisie string, zwraca -1 jeśli nie ma takiego wystąpienia.
 ```

Napisz program pozwalający na interaktywne testowanie zaimplementowanych procedur. Użyj wywołań syscall. Użyj usług print_string i read_string. UWAGA: usługi te dołączają na końcu wprowadzonego ciągu znak nowej linii NL (`0x0a`). Aby dostosować się do konwencji C/C++ (`0x00`) na końcu napisu należy ten znak zastąpić znakiem `0x00`. 

Do testowania przyjmij że dysponujemy czterema napisami:

```
.data
str1: .space 32
str2: .space 32
str3: .space 32
str4: .space 32
```

Zakładamy, że nasze napisy nie będą dłuższe niż 31 (dla wygody obserwowania wyników w debugerze).

Program testowy powinien wykonywać w pętli następujące działania:

+ Program pyta o operację do wykonania
+ Użytkownik wprowadza indeks operacji
+ Jeśli potrzeba - użytkownik podaje parametry do wykonania operacji.
+ Program wykonuje zdaną operację, jeśli operacja dotyczyła funkcji zwracającej wartość - wyświetla wartość zwróconą prze funkcję

Powinny być dostępne następujące operacje

+ Wczytaj napis - program pyta o indeks napisu (1 do 4 co odpowiada wczytywaniu `str1` do `str4`) i o treść napisu
+ Wyświetl napis - program pyta o indeks napisu (1 do 4)
+ Wykonaj strlen
+ Wykonaj strcmp
+ Wykonaj strcat
+ Wykonaj strfind
  
Dla uproszczenia zakładamy, że jeśli funkcja przyjmuje parametry które są napisami to parametry aktualne zawsze są (w kolejności od lewej do prawej): `str1`, `str2`, `str3` itd.

**Which roughly translates to:**

Implement a couple of functions for processing strings. Assume that string are encoded as ASCII (one char occupies one byte). Use C/C++ convention, where the end of the string is determined by `0x00` byte. Assume that function arguments are passed in `$a0`, `$a1`, etc. registers. The return value should be placed in `$v0` register.

Implement the following functions:

```c
int strlen( char *string );
   // calculates length of the string - not including the terminator character
int strcmp( char *sring1, char *string2);
   // compares two string lexicographically
   // -1 - if string1 < string2
   // 0 - if string1 == string2 
   // 1 - if string1 > string2
void strcat( char *dest, char *string1, char *string2 );
   // concatenate string1 and string2, place the result in dest
int strfind( char *string, char *fragment );
   // find the index of the first occurence of fragment in string,
   // return -1 if there is no such occurence
 ```

Write a program that allows to interactively test your implemented procedures. Use system calls. Use print_string and read_string services. CAUTION: these two services are known to append a new line character NL (`0x0a`) to entered string. You should change this character to `0x00`, to follow C/C++ convention.

To do some testing, assume we have 4 strings in memory:

```
.data
str1: .space 32
str2: .space 32
str3: .space 32
str4: .space 32
```

We also assume that our string won't be longer than 31 chars (for convenience of observing the results in debugger).

The test program should repeatedly do the following:

+ Ask for the operation to perform
+ The user enters its index
+ Only if needed - user enters parameters required to complete the operation
+ Program performs the given operation and if it returns a value - displays it

The following operations should be available:

+ Read string - program asks for its index (1 to 4 which corresponds to strings `str1`-`str4`) and content
+ Print string - program asks for its index (1 do 4)
+ Perform strlen
+ Perform strcmp
+ Perform strcat
+ Perform strfind
  
For the sake of ease, we assume that if the function accepts parameters that are strings, its first (srarting from the left) string parameter will be `str1`, second - `str2` and so on.

