all: EasyBMP_UserManual.dvi EasyBMP_UserManual.pdf

EasyBMP_UserManual.dvi: EasyBMP_UserManual.tex rgb.tex
	latex EasyBMP_UserManual.tex

EasyBMP_UserManual.pdf: EasyBMP_UserManual.dvi
	dvipdfm EasyBMP_UserManual.dvi
	
clean:
	rm -f *.log
