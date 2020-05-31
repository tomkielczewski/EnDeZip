#!/bin/bash

# Author           : Tomasz Kiełczewski tomkielczewski@wp.pl
# Created On       : 12.04.2017
# Last Modified By : Tomasz Kiełczewski tomkielczewski@wp.pl
# Last Modified On : 19.04.2017
# Version          : 1.1
#
# Description      : EnDeZip is a bash script to compress and encrypt files
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

function pomoc
{ #Wyświetla krótką pomoc
echo "W menu wybierz opcję, która Cię interesuje, następnie postępuj zgodnie z instrukcjami."
}
function informacja
{ #Wyświetla informacje o autorze i wersji
echo "# Author           : Tomasz Kiełczewski tomkielczewski@wp.pl
# Created On       : 12.04.2017
# Last Modified By : Tomasz Kiełczewski tomkielczewski@wp.pl
# Last Modified On : 19.04.2017
# Version          : 1.1
#
# Description      : EnDeZip is a bash script to compress and encrypt files
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)
"
}
function crypten
{
# crypten - szyfruje pliki używając openssl
# Szyfruje algorytmem 3DES na wejście(-in) podajemy ścieżkę pliku na wyjście(-out) ścieżka pliku z rozszerzeniem "*.des3".
#Komenda uwzględnia też podanie hasła, które jest przechowane w zmiennej HASLO
openssl des3 -salt -in "$NAZWA2$NAZWA" -out "$NAZWA2$NAZWA.des3" -pass pass:$HASLO
}

function cryptde
{

# cryptde -odszyfrowuje pliki używając openssl

openssl des3 -d -salt -in "$NAZWA" -out "${NAZWA%.[^.]*}" -pass pass:$HASLO

}

function pakuj
{
# pakuj - pakuje pliki
# w zależności od wybranego rozszerzenia przez użytkownika uruchamia odpowiedni program(zip, bzip2, gzip, tar)
echo "pakuj: $NAZWA"
NAZWA=${NAZWA##*/}  
case $ROZ in
zip) 
    zip $NAZWA2$NAZWA.zip $NAZWA
    ;;
bz2) 
    bzip2 $NAZWA
    ;;
gz)
    gzip $NAZWA
    ;;
tgz)
    tar -zcvf $NAZWA2$NAZWA.tgz $NAZWA
    ;;
*) echo "złe rozszerzenie!!!";;
esac

}

function odpakuj
{
# pakuj - odpakowuje pliki
# Obsługa wybiera jakie rozszerzenie zawiera plik, przechowuje je w zmiennej ROZ, a ta funkcja wybiera program w zależności od tego rozszerzenia.
# "-o" i "-f" przed ścieżkami pliku odpowiadają za nadpisanie istniejącego pliku.
NAZWA=${NAZWA##*/}  #Usuwa ścieżkę przed nazwą pliku
echo "odpakuj: $NAZWA"
case $ROZ in
zip) 
    unzip -o $NAZWA
    ;;
bz2) 
    bunzip2 -f $NAZWA
    ;;
gz)
    gunzip -f $NAZWA
    ;;
tgz)
    tar -zxvf $NAZWA
    ;;
*) zenity --warning --text "Złe rozszerzenie "
;;
esac
}

function obsluga  #obsługuje wybór z menu i wywołuje odpowiednie funkcje
{
case $KONIEC in
1) # Pakowanie i szyfrowanie
    NAZWA=`zenity --file-selection`
    if [[ -z "$NAZWA" ]]; then #Gdy użytkownik nie wybierze pliku, na przykład kliknie anuluj przy wybieraniu, wyświetli odpowiedni komunikat.
        zenity --warning --text "Nie wybrano pliku!"
        menu;

    else
        meni2=("zip" "bz2" "gz" "tgz")
        ROZ=`zenity --list --column=Menu "${meni2[@]}" --height 300`
        if [[ -z "$ROZ" ]]; then # Analogicznie jak z wybiorem pliku
            zenity --warning --text "Nie wybrano rozszerzenia!"
            menu;
        elif [ $ROZ == "tgz" ] || [ $ROZ == "zip" ] ;then
           # NAZWA2=`zenity --entry --title "Nazwa pliku" --text "Podaj nazwę archiwum, domyślnie jest to nazwa pliku: "`
            NAZWA2=`zenity --file-selection --directory` #Wybór doceloej ścieżki tylko dla zip i tar
            if [[ -z "$NAZWA2" ]]; then  
                NAZWA2="" 
            else
                NAZWA2="$NAZWA2/"            
            fi
            pakuj
            HASLO=`zenity --password`
            NAZWA="$NAZWA.$ROZ"
            crypten
        else
            pakuj
            HASLO=`zenity --password`
            NAZWA="$NAZWA.$ROZ"
            crypten 
        fi    
    fi
;;
2) # Rozpakowywanie zaszyfrowanego pliku
    NAZWA=`zenity --file-selection`
    VAR=${NAZWA##*.} 
    if [[ $VAR == "des3" ]];then #nie rozszyruje pliku, który ma inne rozszerzenie
        if [[ -z "$NAZWA" ]]; then
            zenity --warning --text "Nie wybrano pliku!"
            menu;

        else
            HASLO=`zenity --password`
            cryptde 
            NAZWA=${NAZWA%.*} #ucina z nazwy ścieżkę zostawia samą nazwę z rozszerzeniem
            ROZ=${NAZWA##*.}  #Wybiera samo rozszerzenie
            odpakuj
        fi
    else 
            zenity --warning --text "Ten plik nie jest zaszyfrowany! 
Wystąpił problem z obsługą pliku, sprawdź czy wybrałeś(aś) dobrą opcję"
            menu;
    fi
;;
3) # Pakowanie
    NAZWA=`zenity --file-selection`
    if [[ -z "$NAZWA" ]]; then
        zenity --warning --text "Nie wybrano pliku!"
        menu;

    else
        meni2=("zip" "bz2" "gz" "tgz")
        ROZ=`zenity --list --column=Menu "${meni2[@]}" --height 300`
        #Użytkownik musi wybrać z jakim rozszerzeniem pakować plik
        if [[ -z "$ROZ" ]]; then
            zenity --warning --text "Nie wybrano rozszerzenia!"
            menu;

        elif [ $ROZ == "tgz" ] || [ $ROZ == "zip" ] ;then
           # NAZWA2=`zenity --entry --title "Nazwa pliku" --text "Podaj nazwę archiwum, domyślnie jest to nazwa pliku: "`
            NAZWA2=`zenity --file-selection --directory` #Wybór doceloej ścieżki tylko dla zip i tar
            if [[ -z "$NAZWA2" ]]; then  
                NAZWA2="" 
            else
                NAZWA2="$NAZWA2/"            
            fi
            pakuj
     
        else
            pakuj
        fi
    fi
;;
4) # Rozpakowywanie
    
    NAZWA=`zenity --file-selection`
    if [[ -z "$NAZWA" ]]; then
        zenity --warning --text "Nie wybrano pliku!"
        menu;

    else
        ROZ=${NAZWA##*.} 
        odpakuj
    fi
;;
5) # Szyfrowanie
    NAZWA=`zenity --file-selection`
    if [[ -z "$NAZWA" ]]; then
        zenity --warning --text "Nie wybrano pliku!"
        menu;
    else

        HASLO=`zenity --password`
        if [[ -z "$HASLO" ]]; then
            zenity --warning --text "Nie podano hasła!"
            menu;
        else
            crypten
        fi
    fi
;;
6) # Rozszyfrowywanie
    NAZWA=`zenity --file-selection`
    if [[ -z "$NAZWA" ]]; then
        zenity --warning --text "Nie wybrano pliku!"
        menu;
    else

        HASLO=`zenity --password`
        if [[ -z "$HASLO" ]]; then
            zenity --warning --text "Nie podano hasła!"
            menu;
        else
            cryptde
        fi
    fi
;;
7)  #Koniec

;;
esac
}

function menu # poczatek menu
{
until [[ $KONIEC = 7 ]];do

echo $KONIEC;

ROZ="";
NAZWA="";
NAZWA2="";
HASLO="";

meni=("1 - Pakowanie i szyfrowanie" "2 - Rozpakowywanie zaszyfrowanego pliku" "3 - Pakowanie " "4 - Rozpakowywanie" "5 - Szyfrowanie" "6 - Rozszyfrowywanie"  "7 - Koniec")
odp=`zenity --list --column=Menu "${meni[@]}" --height 400 --width 300`
if [[ $? -eq 1 ]]; then
KONIEC="7";
else
case $odp in
	"${meni[0]}" )
	KONIEC="1"
	;;
	"${meni[1]}" )
	KONIEC="2"
	;;
	"${meni[2]}" )
	KONIEC="3"
	;;
	"${meni[3]}" )
	KONIEC="4"
	;;
	"${meni[4]}" )
	KONIEC="5"
	;;
	"${meni[5]}" )
	KONIEC="6"
	;;
	"${meni[6]}" )
	KONIEC="7"
	;;
	*) echo "nie wybrano";;
	
esac
fi
obsluga;

done;
}

while getopts vh WYBOR 2>/dev/null
    do
	case $WYBOR in
	    h) pomoc
            exit;;
	    v) informacja
            exit;;
	    ?) echo "Nieprawidłowa opcja, wpisz -h w celu uzyskania pomocy."
	       exit;;
	esac	
    done

menu;
