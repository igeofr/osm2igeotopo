###################################################
#SOURCE : https://github.com/carey136/Standalone-Export-Atlas-QGIS3
###################################################
#### importing libraries ####
import sys
import os
import glob # allows for all files in a certain directory to be targeted

from os.path import *
from qgis.core import *
from PyQt5.QtCore import *
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
#import argparse

import stat
sys.path.append('/Applications/QGIS3.10.app/Contents/Resources/python/')
sys.path.append('/Applications/QGIS3.10.app/Contents/Resources/python/plugins') # if you want to use the p
os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = '/Applications/QGIS3.10.app/Contents/Plugins'

gdal_data = os.environ['GDAL_DATA']
gcs_csv = os.path.join(gdal_data, 'gcs.csv')
print('is file: ' + str(os.path.isfile(gcs_csv)))
st = os.stat(gcs_csv)
print('is readable: ' + str(bool(st.st_mode & stat.S_IRGRP)))
#parser = argparse.ArgumentParser()
#parser.add_argument('-P',metavar=('\"Project file\"'), help='Usage: Override QGS project file')
#parser.add_argument('-F',nargs=3,metavar=('\"Column\"','\"operator\"','\"value\"'),help='Usage: Override Atlas filter')
#parser.add_argument('-C',metavar=('\"Coverage Layer Name\"'), help='Usage: Override atlas coverage layer')
#parser.add_argument('-O',metavar=('\"Output Format\"'),help='Usage: Either "image" or "pdf" (default)')
#parser.add_argument('-D',metavar=('\"Output Directory\"'), help='Usage: Override output directory (exclude trailing "\\"')
#parser.add_argument('-N',metavar=('\"Output Name\"'),help='Usage: Override image output name using unique value query. e.g. \"@atlas_featurenid\"')
#parser.add_argument('-Q',metavar=('\"Output pdf Name\"'), help='Usage: Override output name for PDFs (cannot parse column values as image filter can')
#parser.parse_args()

####      Hardcode variables here      ####
#### Or use flags to override defaults ####

# -P = Project file
myProject = '/osm2igeotopo/X_PROJET_OSM2IGEOTOPO_V1.qgs'

# -L = Layout ("Layout name")
layoutName = 'EXPORT_DALLE'

# -C = Coverage Layer Name ("Layer Name")
coverageLayer = 'Grille'

# -F = filter ("column" "operator" "value")
#atlasFilter = ''

# -O = Output Format (pdf or image)
outputFormat = 'image'

# -D = Output Directory ("c:your\output" - exclude trailing "\")
outputFolder = '/osm2igeotopo/OSM2IGEOTOPO/07_EXPORT/'

# -N = Image output Query
outputName = "format_date(now(),'yyyy_MM_dd') || '_OSM2IGEOTOPO_' || if(to_int( (x_min(@atlas_geometry )))<1000000,'0' ||left(x_min(@atlas_geometry ),3),left(x_min(@atlas_geometry ),4))  || '_'  || if(to_int( (y_max(@atlas_geometry )))<1000000,'0' ||left(y_max(@atlas_geometry ),3),left(y_max(@atlas_geometry ),4)) || '_L93'" #e.g.\"Parish\" || \' \' || \"Number\" where parish and number are columns

# -Q = PDF Name
pdfName = 'Export'


#### Setting variables using flags ####
#if("-P" in sys.argv): myProject = sys.argv[sys.argv.index("-P") + 1]
#if("-L" in sys.argv): layoutName = sys.argv[sys.argv.index("-L") + 1]
#if("-C" in sys.argv): coverageLayer = sys.argv[sys.argv.index("-C") + 1]
#if("-F" in sys.argv): atlasFilter = "\"" + sys.argv[sys.argv.index("-F") + 1] + "\" " + sys.argv[sys.argv.index("-F") + 2] + " \'" + sys.argv[sys.argv.index("-F") + 3] + "\'"
#if("-O" in sys.argv): outputFormat = sys.argv[sys.argv.index("-O") + 1]
#if("-D" in sys.argv): outputFolder = sys.argv[sys.argv.index("-D") + 1]
#if("-N" in sys.argv): outputName = sys.argv[sys.argv.index("-N") + 1]
#if("-Q" in sys.argv): pdfName = sys.argv[sys.argv.index("-Q") + 1]

#### Initialising QGIS in back end (utilising users temp folder) ####
#home = expanduser("~")
#QgsApplication( [], False, home )
#QgsApplication.setPrefixPath("/Applications/QGIS3.10.app/Contents/MacOS/QGIS", True) #Change path for standalone QGIS install
app = QApplication([])
QgsApplication.initQgis()

#### Defining map path and contents ####

QgsProject.instance().read(myProject)
myLayout = QgsProject.instance().layoutManager().layoutByName(layoutName)
myAtlas = myLayout.atlas()
myAtlasMap = myAtlas.layout()


#### atlas query ####
if(coverageLayer in locals()): myAtlas.setCoverageLayer(QgsProject.instance().mapLayersByName(coverageLayer))

#myAtlas.setFilterFeatures(True)
#myAtlas.setFilterExpression(atlasFilter)

#### image output name ####
myAtlas.setFilenameExpression( outputName )

#### image and pdf settings ####
pdf_settings=QgsLayoutExporter(myAtlasMap).PdfExportSettings()
image_settings = QgsLayoutExporter(myAtlasMap).ImageExportSettings()
image_settings.dpi = 254
image_settings.generateWorldFile = 1
imageExtension = '.jp2'
print('toto2')
#### Export images or PDF (depending on flag) ####
if outputFormat == "image":
    for myLayout in QgsProject.instance().layoutManager().printLayouts():
        if myAtlas.enabled():
            result, error = QgsLayoutExporter.exportToImage(myAtlas, baseFilePath=outputFolder + '/', extension=imageExtension, settings=image_settings)
            if not result == QgsLayoutExporter.Success:
                print(error)
if outputFormat == "pdf":
    for myLayout in QgsProject.instance().layoutManager().printLayouts():
        if myAtlas.enabled():
            result, error = QgsLayoutExporter.exportToPdf(myAtlas, outputFolder + '/' + pdfName + '.pdf', settings=pdf_settings)
            if not result == QgsLayoutExporter.Success:
                print(error)
print("Success!")
QgsApplication.exitQgis()
