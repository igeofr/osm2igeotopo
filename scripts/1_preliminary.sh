##########################
#OSM2IGEOTOPO - FRANCE
##########################

cd "/data_in/oceans_seas"
rm water-polygons-split-4326.*
rm -r water-polygons-split-4326
curl --limit-rate 200K https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip > "./water-polygons-split-4326.zip"
unzip -o water-polygons-split-4326.zip

###----------
cd "/data_in/dsm/"
### ATTENTION : Au préalable, vous devez télécharger et décompresser les différentes tuiles EU-DEM dans le dossier dsm
gdalbuildvrt ./1_VRT.vrt ./*.TIF
