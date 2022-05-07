# Task 2
## Binary Coded Decimal addition

Zaimplementuj procedurę do dodawania liczb o nieograniczonej długości w kodzie BCD (binary coded decimal - opis np. w https://pl.wikipedia.org/wiki/Kod_BCD). Przyjmij następujące założenia:

+ Kodujemy zgodnie z konwencją **packed BCD**, tzn. każdy bajt zawiera dwie cyfry dziesiętne - bardziej znacząca na starszej części bajtów, mniej znacząca na młodszej części bajtu.
+ Cyfry kodowane są w konwencji 8421
+ Najbardziej znacząca cyfra znajduje się w starszej części bajtu, tzn. liczba zawsze zaczyna się (po stronie najbardziej znaczącej) od starszego półbajtu.
+ Liczby mogą być dowolnej długości - kolejne cyfry (od najbardziej znaczącej do najmniej znaczącej) znajdują się w kolejnych bajtach.
+ Dla rozpoznania końca liczby za najmniej znaczącą cyfrą umieszczamy półbajt `0xf`.
+ Dodawane liczby są nieujemne.
+ Dodawane liczby mogą mieć różną długość - nie zakładamy dopełniania nieznaczącymi zerami (ale liczba z nieznaczącymi zerami też może wystąpić jako składnik dodawania).
+ Wynik dodawania nigdy nie zawiera poprzedzających nieznaczących zer.
+ Liczby do dodania znajdują się w obszarze danych globalnych (`.data`). Wynik również
umieszczamy w tym obszarze.
+ Procedura dodawania otrzymuje trzy adresy:
  + adres początku pierwszego składnika - w rejestrze `$a0`
  + adres początku drugiego składnika- w rejestrze `$a1`
  + adres początku wyniku - w rejestrze `$a2`
+ Zakładamy, że pod adresem początku wyniku jest wystarczająca ilość wolnego miejsca aby pomieścić cały wynik (który może być dłuższy od obydwu dodawanych liczb). Obsłuż  prawidłowo wywołanie i powrót z procedury. Zaproponuj i zaimplementuj sposób przetestowania napisanej procedury.

**Which roughly translates to:**

Implement a procedure for adding non-limited numbers encoded as BCD (Binary Coded Decimal - description here: https://en.wikipedia.org/wiki/Binary-coded_decimal). Assume that:

+ Numbers are encoded according to **packed BCD** convention, i.e. every byte contains two decimal digits - the more significant one is stored in the more significant nibble.
+ Digits are encoded as 8421.
+ The most significant digit is always stored in bits 7-4, i.e. every number starts with more significant bits.
+ Numbers can be of any length - subsequent digits (starting with the most significant one) are stored in subsequent bytes.
+ Every number ends with a `0xf` nibble to allow determining its length.
+ Added numbers are non-negative.
+ Added numbers can differ in length - we can't assume that they're complemented with non-significant zeros (however a number that starts with zeros can appear as a sum addend).
+ The calculated sum never contains any non-significant zeros.
+ Numbers to add are placed in global data section (`.data`). The sum should also be stored there.
+ Your addition procedure receives 3 addresses:
  + Start address of the first addend - in `$a0` register
  + Start address of the second addend - in `$a1` register
  + Start address of the sum - in `$a2` register
+ Assume that there is enough space to hold the whole result (which may be longer than either of the two added numbers) under the sum address. Ensure to handle calling and returning from procedure correctly. Propose and implement a way to test your procedure.
