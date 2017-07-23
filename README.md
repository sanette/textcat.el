# textcat.el
emacs mode for libtextcat - automatic language recognition

(directly adapted from http://os.inf.tu-dresden.de/~mp26/emacs.shtml)

When calling ```'textcat-change-ispell-dictionary```
the language of the buffer will be automatically detected (by statistics) and the correct ispell/flyspell dictionary will be selected.

Save textcal.el whereever you want, and install textcat from their website: http://software.wise-guys.nl/libtextcat/
as follows.

## install textcat:
```bash
wget http://software.wise-guys.nl/download/libtextcat-2.2.tar.gz
tar xvf libtextcat-2.2.tar.gz
cd libtextcat-2.2/
./configure --prefix=/usr/local/lib/textcat
make
sudo make install
```

## install testtextcat:
```bash
cd langclass; sed -i 's|LM/|/usr/local/lib/textcat/LM/|g' conf.txt
cd ..
sudo cp src/.libs/testtextcat /usr/local/lib/textcat/
sudo cp -r langclass/* /usr/local/lib/textcat/
```

## using with thunderbird
You will get automatic language recognition when replying to an email, if you use the "external editor" extension.

If you don't want to have textcat.el loaded by default by emacs,
instead of calling emacs, call a wrapper that will load the necessary library, like this:

```sh
#!/bin/sh

emacs -Q -l $HOME/prog/emacs/thunderbird.el $@
```
where thunderbird.el should contain at least:
```elisp
(load "$HOME/.emacs-perso/textcat") ;; adapt this to your textcal.el path.
(add-hook 'flyspell-mode-hook 'textcat-change-ispell-dictionary)
```
