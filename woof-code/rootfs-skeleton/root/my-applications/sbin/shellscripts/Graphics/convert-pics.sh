#!/bin/sh
#####
###
###So 9. Okt 09:15:43 GMT-1 2011
#####

func_xpm_to_ppm(){
F=`find . -type f -name "*xpm"`

###here the transparen alpha channel gets black:
for i in $F; do N=${i%.*}; echo $N; xpmtoppm $i >$N.ppm;done
###

man_func(){ 
#      --alphaout=alpha-filename
#              xpmtoppm creates a PBM file containing the transparency mask for
#              the  image.   If  the  input  image doesn't contain transparency
#              information, the alpha-filename file contains all white (opaque)
#              alpha  values.   If  you don't specify --alphaout, xpmtoppm does
#              not generate an alpha file, and if the input  image  has  trans-
#              parency information, xpmtoppm simply discards it.

#      --alphaout=alpha-filename
#              xpmtoppm creates a PBM file containing the transparency mask for
#              the  image.   If  the  input  image doesn't contain transparency
#              information, the alpha-filename file contains all white (opaque)
#              alpha  values.   If  you don't specify --alphaout, xpmtoppm does
#              not generate an alpha file, and if the input  image  has  trans-
#              parency information, xpmtoppm simply discards it.

#              If you specify - as the filename, xpmtoppm writes the alpha out-
#              put to Standard Output and discards the image.

#              See pnmcomp(1) for one way to use the alpha output file.

#      --verbose
#              xpmtoppm prints information about  its  processing  on  Standard
#              Error.
}



}

func_ppm_to_pgm(){
PPM=`find . -type f -name "*.ppm"`

for i in $PPM ; do N=${i%.ppm};echo $N; ppmtopgm $i >$N.pgm;done


}

func_pgm_to_pbm(){
PGM=`find . -name "*.pgm"`

for i in $PGM ; do N=${i%.pgm}; echo $N ; pgmtopbm $i >$N.pbm;done
 

}

func_ppm_to_jpeg(){
PBM=`find . -name "*.pbm"`

for i in $PPM ; do N=${i%.ppm};echo $N; ppmtojpeg $i >$N.jpeg;done


}

func_jpeg_to_pnm(){
JPEG=`find . -name "*.jpeg"`

for i in $JPEG ; do N=${i%.jpeg}; jpegtopnm $i >$N.pnm;done


}

func_pnm_to_png(){
PNM=`find . -name "*.pnm"`

for i in $PNM ; do N=${%.pnm} ; pnmtopng $i >$N.png;done


}


