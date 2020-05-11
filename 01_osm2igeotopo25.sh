#!/bin/bash

##########################
#OSM2IGEOTOPO - FRANCE
##########################

if [ "$#" -ge 1 ]; then
  if [ "$1" = "11_ILE_DE_FRANCE" ]  || [ "$1" = "21_CHAMPAGNE_ARDENNE" ] || [ "$1" = "22_PICARDIE" ] || [ "$1" = "23_HAUTE_NORMANDIE" ] || [ "$1" = "24_CENTRE" ] || [ "$1" = "25_BASSE_NORMANDIE" ] || [ "$1" = "26_BOURGOGNE" ] || [ "$1" = "31_NORD_PAS_DE_CALAIS" ]  || [ "$1" = "41_LORRAINE" ] || [ "$1" = "42_ALSACE" ] || [ "$1" = "43_FRANCHE_COMTE" ] || [ "$1" = "52_PAYS_DE_LA_LOIRE" ] || [ "$1" = "53_BRETAGNE" ] ||  [ "$1" = "54_POITOU_CHARENTES" ] || [ "$1" = "72_AQUITAINE" ] || [ "$1" = "73_MIDI_PYRENEES" ] || [ "$1" = "74_LIMOUSIN" ] || [ "$1" = "82_RHONE_ALPES" ] || [ "$1" = "83_AUVERGNE" ] || [ "$1" = "91_LANGUEDOC_ROUSSILLON" ] || [ "$1" = "93_PROVENCE_ALPES_COTE_D_AZUR" ] || [ "$1" = "94_CORSE" ];
  then
    a_region=$1
  else
  IFS= read -p "REGION : " r_region
  if [ "$r_region" = "11_ILE_DE_FRANCE" ]  || [ "$r_region" = "21_CHAMPAGNE_ARDENNE" ] || [ "$r_region" = "22_PICARDIE" ] || [ "$r_region" = "23_HAUTE_NORMANDIE" ] || [ "$r_region" = "24_CENTRE" ] || [ "$r_region" = "25_BASSE_NORMANDIE" ] || [ "$r_region" = "26_BOURGOGNE" ] || [ "$r_region" = "31_NORD_PAS_DE_CALAIS" ]  || [ "$r_region" = "41_LORRAINE" ] || [ "$r_region" = "42_ALSACE" ] || [ "$r_region" = "43_FRANCHE_COMTE" ] || [ "$r_region" = "52_PAYS_DE_LA_LOIRE" ] || [ "$r_region" = "53_BRETAGNE" ] ||  [ "$r_region" = "54_POITOU_CHARENTES" ] || [ "$r_region" = "72_AQUITAINE" ] || [ "$r_region" = "73_MIDI_PYRENEES" ] || [ "$r_region" = "74_LIMOUSIN" ] || [ "$r_region" = "82_RHONE_ALPES" ] || [ "$r_region" = "83_AUVERGNE" ] || [ "$r_region" = "91_LANGUEDOC_ROUSSILLON" ] || [ "$r_region" = "93_PROVENCE_ALPES_COTE_D_AZUR" ] || [ "$r_region" = "94_CORSE" ];
  then
    export a_region=$r_region
  else
    echo "Erreur de paramètre"
    exit 0
  fi
fi
else
  IFS= read -p "REGION : " r_region
  if [ "$r_region" = "11_ILE_DE_FRANCE" ]  || [ "$r_region" = "21_CHAMPAGNE_ARDENNE" ] || [ "$r_region" = "22_PICARDIE" ] || [ "$r_region" = "23_HAUTE_NORMANDIE" ] || [ "$r_region" = "24_CENTRE" ] || [ "$r_region" = "25_BASSE_NORMANDIE" ] || [ "$r_region" = "26_BOURGOGNE" ] || [ "$r_region" = "31_NORD_PAS_DE_CALAIS" ]  || [ "$r_region" = "41_LORRAINE" ] || [ "$r_region" = "42_ALSACE" ] || [ "$r_region" = "43_FRANCHE_COMTE" ]  || [ "$r_region" = "52_PAYS_DE_LA_LOIRE" ] || [ "$r_region" = "53_BRETAGNE" ] || [ "$r_region" = "54_POITOU_CHARENTES" ] || [ "$r_region" = "72_AQUITAINE" ] || [ "$r_region" = "73_MIDI_PYRENEES" ] || [ "$r_region" = "74_LIMOUSIN" ] || [ "$r_region" = "82_RHONE_ALPES" ] || [ "$r_region" = "83_AUVERGNE" ] || [ "$r_region" = "91_LANGUEDOC_ROUSSILLON" ] || [ "$r_region" = "93_PROVENCE_ALPES_COTE_D_AZUR" ] || [ "$r_region" = "94_CORSE" ];
  then
    export a_region=$r_region
  else
    echo "Erreur de paramètre"
    exit 0
  fi
fi

#-------------------------------------------------------------------------------

rm -rfv /home/osm2igeotopo/data_in/osm2igeo/*

export DATE_T=$(date '+%Y%m')

cd /home/osm2igeotopo/data_in/osm2igeo/
curl https://data.data-wax.com/OSM2IGEO/FRANCE/$DATE_T'_OSM2IGEO_'$a_region'_SHP_L93_2154.zip' > $DATE_T'_OSM2IGEO_'$a_region'_SHP_L93_2154.zip'

cd /home/osm2igeotopo/data_in/osm2igeo/
for f in *.zip;
  do
    export DATE_OLD=$(date -d "-1 month" '+%Y%m')

    unzip -o ${f%%.*}.zip; #Décompresse le dossier
    yes | cp -rf ${f%%.*}/* ./; #Déplace les fichiers
    rm -r ./${f%%.*}
    rm ${f%%.*}.zip
    cd /home/osm2igeotopo/

    rm -r data_temp/*
    rm -r data_out/*

    echo 'Commune 500m'
    ogr2ogr -f "ESRI Shapefile" data_temp/1_COMMUNE_DISSOLVE.shp data_in/osm2igeo/H_OSM_ADMINISTRATIF/COMMUNE.shp -dialect sqlite -sql "SELECT (st_buffer(ST_Union(geometry),500)) FROM COMMUNE"
    echo 'Clip DSM'
    gdalwarp -overwrite -s_srs EPSG:3035 -t_srs EPSG:2154 -dstnodata 9999.0 -tr 20.0 20.0 -r bilinear -co BIGTIFF=YES -of GTiff -multi -cutline data_temp/1_COMMUNE_DISSOLVE.shp -cl '1_COMMUNE_DISSOLVE' -crop_to_cutline data_in/dsm/1_VRT.vrt data_temp/2_IMAGE_CLIP.tif
    echo 'Courbes'
    gdal_contour -b 1 -a ELEV -i 10.0 -f "ESRI Shapefile" data_temp/2_IMAGE_CLIP.tif data_temp/3_COURBES.shp
    echo 'Emprise'
    ogr2ogr -f "ESRI Shapefile" data_temp/4_COMMUNE_DISSOLVE.shp data_in/osm2igeo/H_OSM_ADMINISTRATIF/COMMUNE.shp -dialect sqlite -sql "SELECT ST_Union(geometry) FROM COMMUNE"
    echo 'Clip courbes'
    ogr2ogr -overwrite -progress -f "ESRI Shapefile" -clipsrc data_temp/4_COMMUNE_DISSOLVE.shp data_temp/5_COURBES_CLIP.shp data_temp/3_COURBES.shp
    echo 'Select grille'
    ogr2ogr data_temp/6_GRILLE_SELECT.shp data_in/X_GRILLE.vrt -dialect sqlite -sql "SELECT b.id, b.geometry FROM grille_FRANCE b WHERE st_intersects( (SELECT (st_union(geometry)) FROM COMMUNE), b.geometry)"
    echo 'Mer'
    ogr2ogr -t_srs "EPSG:2154" data_temp/7_WATER_SELECT.shp data_in/X_WATER.vrt -dialect sqlite -sql "SELECT st_union(b.geometry) FROM water_polygons b WHERE st_intersects((SELECT st_transform(st_buffer(st_union(geometry),500),4326) FROM COMMUNE), b.geometry)"
    echo 'Ombrage'
    gdaldem hillshade data_temp/2_IMAGE_CLIP.tif data_temp/8_OMBRAGE_225.tif -of GTiff -b 1 -z 1.5 -s 1.0 -az 225.0 -alt 45.0
    gdaldem hillshade data_temp/2_IMAGE_CLIP.tif data_temp/8_OMBRAGE_360.tif -of GTiff -b 1 -z 1.5 -s 1.0 -az 360.0 -alt 45.0
    gdaldem hillshade data_temp/2_IMAGE_CLIP.tif data_temp/8_OMBRAGE_315.tif -of GTiff -b 1 -z 1.5 -s 1.0 -az 315.0 -alt 45.0
    gdaldem hillshade data_temp/2_IMAGE_CLIP.tif data_temp/8_OMBRAGE_270.tif -of GTiff -b 1 -z 1.5 -s 1.0 -az 270.0 -alt 45.0

    rm -r data_temp/dalles_export;
    mkdir data_temp/dalles_export;
    python3 scripts/export_atlas.py;

    for j in data_temp/dalles_export/*.tiff; do gdal_translate -b 1 -b 2 -b 3 -mask 4 -of GTiff -co COMPRESS=JPEG -co JPEG_QUALITY=90 -co PHOTOMETRIC=YCBCR -co TFW=YES data_temp/dalles_export/${j##*/} data_out/${j##*/} ;  done
    ##En option si l'on souhaite ajouter un qml
    for i in data_out/*.tiff; do cp attachment/template_osm2igeotopo.qml ${i%%.*}.qml ; done

    rm -r data_temp/dalles_export;
    NAME_OSM2IGEO=${f%%.*};
    NAME_TERRITOIRE=${NAME_OSM2IGEO:7:100};
    echo ${NAME_TERRITOIRE};
    NAME_FOLDER1=${NAME_TERRITOIRE//SHP/TIFF};
    NAME_FOLDER=${NAME_FOLDER1//OSM2IGEO/OSM2IGEOTOPO};
    echo ${NAME_FOLDER};
    mkdir data_out/$DATE_T'_'${NAME_FOLDER};
    mkdir data_out/$DATE_T'_'${NAME_FOLDER}/TUILES;
    mv data_out/*.* data_out/$DATE_T'_'${NAME_FOLDER}/TUILES/;
    cp attachment/X_Licence.txt data_out/$DATE_T'_'${NAME_FOLDER}/X_Licence.txt;

    ls data_out/$DATE_T'_'${NAME_FOLDER}/TUILES/*.tiff > data_temp/list_img.txt
    gdalbuildvrt -resolution average -addalpha -r nearest -input_file_list data_temp/list_img.txt data_out/$DATE_T'_'${NAME_FOLDER}/$a_region'.vrt'
    for i in data_out/$DATE_T'_'${NAME_FOLDER}/*.vrt; do cp attachment/template_osm2igeotopo.qml ${i%%.*}.qml ; done

    cd data_out;
    ##Si l'on souhaite sciender le zip : -s 500m
    zip -r $DATE_T'_'${NAME_FOLDER}.zip $DATE_T'_'${NAME_FOLDER};
    rm -r $DATE_T'_'${NAME_FOLDER};

    ##Permet d'exporter les données sur un serveur FTP
    curl -s -T $DATE_T'_'${NAME_FOLDER}.zip ftp://ftp-xxxxxxx/FRANCE/ --user "IDENTIFIANT:PASSWORD"
    curl -s -u "IDENTIFIANT:PASSWORD" "ftp://ftp-xxxxxxx/FRANCE/" -Q "-DELE $DATE_OLD'_'${NAME_FOLDER}.zip"

    ##Permet de supprimer le fichier zip généré après l'envoi sur un serveur FTP
    rm -r $DATE_T'_'${NAME_FOLDER}.zip

    cd /home/osm2igeotopo/
    #rm -r data_temp/*
    ##Permet de supprimer les données OSM2IGEOTOPO en entrée
    rm -rfv data_in/osm2igeo/*

done
