##########################
#OSM2IGEOTOPO - FRANCE
##########################

cd /osm2igeo/data_in/osm2igeo/
for f in *.zip;
  do
    unzip -o ${f%%.*}.zip; #Décompresse le dossier
    yes | cp -rf ${f%%.*}/* ./; #Déplace les fichiers
    rm -r ./${f%%.*}
    rm ${f%%.*}.zip
    cd /osm2igeo/
    echo 'Commune 500m'
    ogr2ogr -f "ESRI Shapefile" data_temp/1_COMMUNE_DISSOLVE.shp data_in/osm2igeo/H_OSM_ADMINISTRATIF/COMMUNE.shp -dialect sqlite -sql "SELECT (st_buffer(ST_Union(geometry),500)) FROM COMMUNE"
    echo 'Clip DSM'
    gdalwarp -overwrite -t_srs 'EPSG:2154' -r cubicspline -of GTiff -multi -cutline data_temp/1_COMMUNE_DISSOLVE.shp -cl '1_COMMUNE_DISSOLVE' -crop_to_cutline data_in/dsm/1_VRT.vrt data_temp/2_IMAGE_CLIP.tif
    echo 'Courbes'
    gdal_contour -b 1 -a ELEV -i 10.0 -f "ESRI Shapefile" data_temp/2_IMAGE_CLIP.tif data_temp/3_COURBES.shp
    echo 'Emprise'
    ogr2ogr -f "ESRI Shapefile" data_temp/4_COMMUNE_DISSOLVE2.shp data_in/osm2igeo/H_OSM_ADMINISTRATIF/COMMUNE.shp -dialect sqlite -sql "SELECT ST_Union(geometry) FROM COMMUNE"
    echo 'Clip courbes'
    ogr2ogr -overwrite -progress -f "ESRI Shapefile" -clipsrc data_temp/4_COMMUNE_DISSOLVE2.shp data_temp/5_COURBES_CLIP.shp data_temp/3_COURBES.shp
    echo 'Select grille'
    ogr2ogr data_temp/6_GRILLE_SELECT.shp data_in/X_GRILLE.vrt -dialect sqlite -sql "SELECT b.id, b.geometry FROM grille_FRANCE b WHERE st_intersects( (SELECT (st_union(geometry)) FROM COMMUNE), b.geometry)"
    echo 'Mer'
    ogr2ogr -t_srs "EPSG:2154" data_temp/7_WATER_SELECT.shp data_in/X_WATER.vrt -dialect sqlite -sql "SELECT st_union(b.geometry) FROM water_polygons b WHERE st_intersects((SELECT st_transform(st_buffer(st_union(geometry),500),4326) FROM COMMUNE), b.geometry)"

    /Applications/QGIS3.10.app/Contents/MacOS/bin/python3 scripts/3_export_atlas.py
    for i in data_out/*.jp2; do cp attachment/template.qml ${i%%.*}.qml ; done

    NAME_OSM2IGEO="201911_42_ALSACE_SHP_L93_2154";
    NAME_TERRITOIRE=${NAME_OSM2IGEO:7:100};
    echo ${NAME_TERRITOIRE};
    NAME_FOLDER=${NAME_TERRITOIRE//SHP/JP2};
    echo ${NAME_FOLDER};
    rm -r ${NAME_FOLDER}
    mkdir data_out/${NAME_FOLDER}
    mkdir data_out/${NAME_FOLDER}/TUILES
    mv data_out/*.* data_out/${NAME_FOLDER}/TUILES/
    cp attachment/X_Licence.txt data_out/${NAME_FOLDER}/X_Licence.txt

    cd data_out
    zip -r -s 500m ${NAME_FOLDER}.zip ${NAME_FOLDER}

done
