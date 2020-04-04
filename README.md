## Pesukonevahti
Kun sovelluksen ajaa, niin se tarkastaa, onko pesukone k‰ynniss‰. Mik‰li pesukone on vapaana ohjelma soittaa ‰‰niviestin.

### Sovelluksen luominen
1. Asenna [Steel Bank Common Lisp](http://www.sbcl.org/).
2. Luo ‰‰nitiedosto tervehdys.mp3 kotihakemistoosi. T‰m‰ tiedosto soitetaan jos pesukone on vapaana.
3. Aja komento "sbcl --load createExecutable.lisp"
3. Aja tiedosto vahti ja anna sille parametreina k‰ytt‰j‰tunnus ja salasana. Esim. ./vahti kayttaja salasana.

### Huomioita Windowsilla k‰‰nt‰miseen
Jotta ohjelman luominen onnistuu windowsilla, pit‰‰ libao-4.dll ja libmpg123.dll lis‰t‰ samaan kansioon, miss‰ sbcl.exe on. Toinen tapa on lis‰t‰ kansioiden polut PATH-ymp‰ristˆmuuttujaan [Linkki](https://tietokoneblogi.wordpress.com/2018/07/26/java-ymparistomuuttujan-asettaminen-windows-10-jarjestelmassa/)