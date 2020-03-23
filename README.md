## Pesukonevahti
Kun sovelluksen ajaa, niin se tarkastaa, onko pesukone käynnissä. Mikäli pesukone on vapaana ohjelma soittaa ääniviestin.

### Sovelluksen luominen
1. Asenna [Steel Bank Common Lisp](http://www.sbcl.org/).
2. Luo äänitiedosto tervehdys.mp3 kotihakemistoosi. Tämä tiedosto soitetaan jos pesukone on vapaana.
3. Aja komento "sbcl --load createExecutable.lisp"
3. Aja tiedosto vahti ja anna sille parametreina käyttäjätunnus ja salasana. Esim. ./vahti kayttaja salasana.