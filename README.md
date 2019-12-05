# **osm2igeotopo**

**[Télécharger les données générées sur la France métropolitaine, les DOM-TOM](https://cloud.data-wax.com/)** ([Découpage suivant les anciennes régions](https://fr.wikipedia.org/wiki/Région_française)).

---
## Objectif du projet

Utiliser la richesse des informations disponibles dans [OpenStreetMap](https://www.openstreetmap.fr) et les valoriser sous la forme d'une carte topographique libre au 1/25 000 (pseudo [SCAN25® | IGN](https://professionnels.ign.fr/scan25)) afin qu'elles puissent être librement exploitées dans une application SIG ou plus simplement imprimées.

## Rendu proposé
![Exemple sur Montpellier Nord V1](exemples_visuels/osm2igeotopo25_1.jpg)

## Pourquoi cette idée ?

Après la création  du projet [OSM2IGEO](https://github.com/igeofr/osm2igeo), j'ai constaté qu'il n'existait pas de carte topographique "libre" ormis le projet Web : [OpenTopoMap](https://opentopomap.org) mais qui ne répond pas à certains besoins de portabilité.

En m'appuyant sur les données générées pour [OSM2IGEO](https://github.com/igeofr/osm2igeo), j'ai donc poursuivi mes travaux pour produire une chaine de traitement permettant de générer et de communiquer des données topographiques sous forme de tuiles de 10*10km.


## Les données générées
**[Télécharger les données générées sur la France métropolitaine, les DOM-TOM](https://cloud.data-wax.com/)** ([Découpage suivant les anciennes régions](https://fr.wikipedia.org/wiki/Région_française)).
A plus long terme, nous aimerions générer des cartes topographiques sur l'Afrique Francophone ou ce type de carte est difficilement accessible.

**Attention :** Les fichiers générés ne respectent pas les spécifications du [SCAN25® | IGN](https://professionnels.ign.fr/scan25) ils visent seulement à s'en rapprocher pour pallier à un besoin de données/informations libres.


## Origine des données

1. Les données OpenStreetMap utilisées pour générer les fichiers vectoriels régionaux proviennent de [Geofabrik](https://download.geofabrik.de/europe/france.html) et sont ensuite mis en formes dans le cadre du projet [OSM2IGEO](https://github.com/igeofr/osm2igeo).

2. Le modèle numérique utilisé provient du projet européen EU-DEM (V1.1) disponible via le site internet de [Copernicus](https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1) - Nota : inscription obligatoire. La résolution de  ce produit est de 25 mètres.

*Il est possible d'adapter ce projet pour utiliser des données OSM provenant d'autres sources.*

## Les points forts

  * Adaptabilité de la chaîne
  * Donnée ouverte basée sur le projet collaboratif [OpenStreetMap](https://www.openstreetmap.fr)
  * Couverture régionale
  * Mise à jour en continu possible

## Les points faibles

  * Hétérogénéité spatiale & attributaire (Hétérogénéités des sources et des compétences des contributeurs).
  * Rendu à améliorer sur certains points.

## Formats

* jp2000 (prochainement remplacé par un format  plus ouvert : .tif).

*Il est possible d'envisager d'autres formats si le besoin se fait sentir.*

## Projections disponibles

* Pour la France métropole : (RGF 93) projection Lambert-93 (EPSG : 2154)
* Pour les DOM-TOM : (Prochainement)

*Il est possible de générer les fichiers dans d'autres systèmes de projection.*

## Mises à jour
Nous allons essayer de proposer une mise à jour chaque six mois.

## Pré-requis et étapes de la chaine de traitement osm2igeotopo

#### Pré-requis

Télécharger la police d'écriture  [Noto Sans Display Condensed](https://www.google.com/get/noto/) - *Proposée par Romain Lacroix dans son tuto : [Carte Topo avec QGIS](https://github.com/rxlacroix/CarteTopo)*


#### Des données à la carte - Etapes

##### 1. Téléchargement des données
1.1.  Télécharger le modèle numérique de terrain EU-DEM (V1.1) disponible via le site internet de [Copernicus](https://land.copernicus.eu/imagery-in-situ/eu-dem/eu-dem-v1.1) - Nota : inscription obligatoire.
    * Pour la France métropolitaine télécharger les tuiles : E30N20 (principale), E30N30, E40N20  (un fichier pouvant peser jusqu'à 5Go)  - Système de projection européen ETRS89 (EPSG:3035).

* Créer un raster virtuel regroupant les différentes tuiles EU-DEM :

      cd "/OSM2IGEOTOPO/"
      gdalbuildvrt dsm/1_VRT.vrt  dsm/*.tif

1.2. Télécharger les zones maritimes depuis le site : [https://osmdata.openstreetmap.de](https://osmdata.openstreetmap.de)

    cd "/OSM2IGEOTOPO/"
    curl --limit-rate 100K https://osmdata.openstreetmap.de/download/water-polygons-split-4326.zip > "oceans_seas/water-polygons-split-4326.*"

1.3. Télécharger la région [OSM2IGEO](https://cloud.data-wax.com) qui vous intéresse au format SHP et la placer dans le dossier : **00_IN**

    cd "/OSM2IGEOTOPO/"
    curl -J -O --limit-rate 100K "LIEN_A_COMPLETER"

##### 2. Préparation des données
*Le script OSM2IGEOTOPO25.sh exploite la puissance de gdal et d'ogr2ogr pour traiter l'information.*

  - 2.1. Décompression des données [OSM2IGEO](https://cloud.data-wax.com)
  - 2.2. Création d'une zone tampon de 500m autour des communes de la région concernée
  - 2.3. Découpage du modèle numérique sur la région concernée
  - 2.4. Création des courbes de niveau
  - 2.5. Création d'un fichier de l'emprise régionale
  - 2.6. Découpage des courbes de niveau suivant  ce fichier d'emprise régionale
  - 2.7. Sélection des mailles recouvrant la région choisie
  - 2.8. Sélection des zones maritimes bordant la région

##### 3. Mise en forme des données
Pour faciliter la mise en forme des données nous avons travaillé avec le logiciel libre [QGIS3](https://www.qgis.org).

  - 3.1. La mise en forme des labels se base sur [notre script de mise en forme des toponymes suivant les règles de l'IGN](https://github.com/igeofr/qgis2/blob/master/expressions/mise_en_forme_des_toponymes_V2_beta.txt)
  - 3.2. L'orientation des labels est réalisée à l'aide du code :

        CASE
          WHEN angle_at_vertex($geometry,1) <= 180
          THEN ''
            ELSE "NUMERO"
        END

Source : https://gis.stackexchange.com/questions/116697/one-label-for-two-lane-roads-osm-qgis-postgis/322816#322816

  - 3.3. La symbologie a été adapté du projet de Romain Lacroix : [Carte Topo avec QGIS](https://github.com/rxlacroix/CarteTopo)  

##### 4. Export automatisé
L'export est automatisé par un script python qui s'appuye sur l'API de QGIS et qui se base sur le projet suivant : [Standalone Export Atlas QGIS3](https://github.com/carey136/Standalone-Export-Atlas-QGIS3) - Nota : Ne fonctionne pas avec la rerojection à la volée notamment pour le DSM mais on est sur le coup.

## Pistes d'évolution
* Compléter nos travaux OSM2IGEO pour compléter le rendu (bornes géodésiques, points de vue, surfaces en eau, chemin de randonnée GR,...)
* Créer une légende
* Créer un fichier de métadonnées
* Affiner certaines requêtes
* Améliorer le rendu du projet QGIS (couleurs, labels, orientation des symboles ...)
* Améliorer la  recette pour le rendu du modèle numérique et le calcul des courbes de niveau ([Des cartes topographiques avec OpenStreetMap](https://blog.champs-libres.coop/carto/2018/12/18/openardennemap.html))
* Ajouter des courbes de niveau en zone maritime : [GEBCO_2019 grid](https://www.gebco.net/data_and_products/gridded_bathymetry_data/#a1)

## Licence
Les données sont fournies sous licence ODbL (Open Database Licence). Cette licence implique : l'attribution et le partage à l'identique.

*	Pour la mention d'attribution veuillez indiquer « osm2igeotopo par DATA\WAX - © les contributeurs d’OpenStreetMap ».
*	Pour le partage à l'identique, toute amélioration des données de osm2igeo doit être repartagée sous licence identique.

## Merci
Nous remercions tous les contributeurs du  projet OpenStreetMap qui enrichissent quotidiennement cette base de données géographique mondiale.

## Le mot de la fin
Merci de nous faire remonter : les erreurs et/ou les problèmes que vous rencontrez.

Pour toute question concernant le projet ou le jeu de données, vous pouvez me contacter : florian.boret)at(data-wax.com

---
## Pour aller plus loin :
* [Carte Topo avec QGIS](https://github.com/rxlacroix/CarteTopo)  
* [Des cartes topographiques avec OpenStreetMap](https://blog.champs-libres.coop/carto/2018/12/18/openardennemap.html)
* [De belles courbes de niveau](https://www.champs-libres.coop/blog/post/2019-11-21-beautiful-contour-belgium/)
* [OpenTopoMap](https://opentopomap.org)
* [Réaliser un fond de carte en relief](http://bota-phytoso-flo.blogspot.com/2015/08/realiser-un-fond-de-carte-en-relief.html)
* [Comment lire une carte topographique - Partie1](https://blog.twonav.fr/tutoriels-land/lire-carte-topographique-2eme-partie/)
* [Comment lire une carte topographique - Partie2](https://blog.twonav.fr/uncategorized/comment-lire-carte-topographique/)
* [RandoCarto](http://randocarto.fr)
