#ETAP 1
#budowanie obraz od podstaw i nadanie mu aliasu 'builder'
FROM scratch AS builder
#deklaracja zmiennej, do której będzie można przekazać wartość w procesie budowania
ARG TEMP_VERSION
#ustawienie katalogu do wykonywania instrukcji
WORKDIR /home/
#kopiowanie plików do wnętrza kontenera
ADD alpine-minirootfs-3.19.1-x86_64.tar /
#aktualizacja i instalacja pakietów oraz czyszczenie cache'a
RUN apk update && \
    apk add nodejs npm && \
    rm -rf /var/cache/apk/*
#skopiowanie pliku z komputera do wnętrz kontenera
COPY ./package.json /home/
#instalacja niezbędnych do uruchomienia aplikacji zależności
RUN npm install
#skopiowanie pliku z komputera do wnętrz kontenera
COPY ./script.js /home/


#ETAP 2
#tworzenie obrazu na podstawie nginx w wersji alpine
FROM nginx:alpine
#przechwycenie zmiennej przekazanej w procesie budowy i zapisanie jej jako globalnej zmiennej środowiskowej z uwzględnieniem
#domyślnej wartości w przypadku, gdy wartość nie zostanie nadana w procesie budowy
ARG TEMP_VERSION
ENV APP_VERSION=${TEMP_VERSION:-version0}
#ustawienie katalogu bazowego, w kótrym będą wykonywanie instrukcje
WORKDIR /usr/share/nginx/html/
#aktualizacja i instalacja pakietów oraz czyszczenie cache'a
RUN apk update && \
    apk add nodejs && \
    rm -rf /var/cache/apk/*
#skopiowanie wszystkich plików z katalogu /home/ pierwszego kontenera do katalogu /usr/share/nginx/html/ drugiego kontenera
COPY --from=builder /home/. /usr/share/nginx/html/
#skopiowanie pliku konfiguracyjnego z komputera do odpowiedniego katalogu wewnątrz kontenera
COPY ./default.conf /etc/nginx/conf.d/
#sprawdzenie poprawności działania kontenera
HEALTHCHECK --interval=15s --timeout=1s \
    CMD curl -f http://localhost:80
#przeładowanie serwera nginx i uruchomienie aplikacji JavaScript
CMD nginx -g "daemon off;" & node script.js
#wystawienie portu 80 do użytku na zewnątrz kontenera
EXPOSE 80