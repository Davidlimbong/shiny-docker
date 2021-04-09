# Deploying shiny Using Docker

Repo ini berisi aplikasi sederhana menggunakan shiny apps. Bagi kalian yang ingin melakukan deployment shiny apps menggunakan docker bisa membaca langkah langkah dibawa ini

1. Install Docker

Pastikan pc anda sudah terinstall docker, jika belum bisa mengunjungi link berikut [docker.com](https://www.docker.com/products/docker-desktop)

2. Siapkan shiny apps

Masukkan file (ui.R, server.R, global.R, data, dll) shiny apps anda dalam satu folder. Pada project ini file tersebut bernama folder `JobGender`

3. Membuat renv.lock file

renv.lock merupakan file yang berisi daftar packages beserta versi yang digunakan pada project ini. File tersebut dapat di generate menggunakan package renv. renv merupakan package yang berfungsi mengatur environments project di R, jika anda ingin membaca lebih dalam tentang renv bisa kunjungi [blog rstudio](https://blog.rstudio.com/2019/11/06/renv-project-environments-for-r/). 

Tahapan membuat file renv,lock sebagai berikut
- Buka rproject (.Rproj) shiny kalian
- Install package `renv`
```
install.packages("renv")
```
- Lakukan init
```
renv::init()
```
Setelah melakukan `init` kalian akan mendapatkan file renv.lock yang berisi daftar packages beserta versinya dalam format json.

4. Membuat Dockerfile

Dockerfile berisi perintah yang harus dilakukan docker ketika ingin build project ini menjadi image. Berikut penjelasan dari isi Dockerfile.


Bagian pertama mengambil image yang sudah tersedia di dockerhub. Pada project ini image yang diambil dari (shiny)[https://hub.docker.com/u/rocker/].

```
# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny:latest
```

Bagian kedua melakukan installasi beberapa linux packages yang digunakan dalam project ini. 
```
# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev
```

Setelah menginstall, package tersebut perlu di update terlebih dahulu. 
```
## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean
```

Selanjutnya pindahkan folder project dari local (PC) ke docker image dengan menggunakan perintah COPY.
```
# copy necessary files
## renv.lock file
COPY /JobGender/renv.lock ./renv.lock

## app folder
COPY JobGender ./app
```
Setelah memindahkan file project, anda dapat menginstall seluruh packages yang dibutuhkan pada project ini dengan memanfaatkan renv.lock yang sudah tersedia.Script dibawah menginstall packages renv terlebih dahulu kemudian menginstall seluruh packages yang terdaftar pada renv.lock dengan function `renv::restore()`

```
# install renv & restore packages
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::restore()'
```

Terakhir kita memesan port yang akan digunakan untuk menjalankan aplikasi ini yaitu pada port 3838, dan setelah itu aplikasi bisa dijalankan dengan function `shiny::runApp()`

```
# expose port
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
```

5. Build Image
setelah semua sudah siap kita bisa membuild app kita yang bernama `jobgender` menjadi sebuah docker image dengan cara

```
docker build -t jobgender .
```
6. save it?
Setelah project anda sudah menjadi image anda bisa menyimpannya dengan cara seperti ini atau jika anda ingin menjalankannya sehingga menjadi container bisa skip tahap ini.
```
docker save -o /home/david/Documents/jobgender.tar jobgender
```

7. run the container
Tahap terakhir anda bisa menjalankan image tersebut menjadi container.
```
docker run -d --rm -p 3838:3838 web
```

TODO:
- menghubungkan docker image dengan database (container juga)
- integrasi dengan shinyproxy