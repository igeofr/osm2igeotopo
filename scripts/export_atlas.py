#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# linja over bruker vi for å kunne bruke æøå uten advarsler.
# Source : https://gis.stackexchange.com/questions/351773/possible-to-automatically-export-atlases-from-qgis-containing-postgresql-views-t
# Autres discussions : https://gis.stackexchange.com/questions/351763/export-several-configured-atlases-with-a-python-script

import sys
import os
import zipfile
os.environ['QT_QPA_PLATFORM']='offscreen'
from PyQt5.QtCore import QSettings
from qgis.core import  QgsApplication, QgsProject, QgsLayoutExporter, QgsLayoutRenderContext

def export_atlas(qgs_project_path, layout_name, outputs_folder):

    # Open existing project
    project = QgsProject.instance()
    project.read(qgs_project_path)

    print('Project in ' + project.fileName() + ' loaded successfully')

    # Open prepared layout that as atlas enabled and set
    layout = project.layoutManager().layoutByName(layout_name)
    myAtlas = layout.atlas()
    myAtlasMap = myAtlas.layout()
    # Export atlas
    exporter = QgsLayoutExporter(layout)
    settings = QgsLayoutExporter.ImageExportSettings()
    image_settings = QgsLayoutExporter(myAtlasMap).ImageExportSettings()

    image_settings.dpi = 300
    image_settings.generateWorldFile = 1

    #source : https://stackoverflow.com/questions/51161361/how-to-disable-anti-aliasing-in-qgis-export-pyqgis
    context = QgsLayoutRenderContext(layout)
    context.setFlag(context.FlagAntialiasing, True)
    image_settings.flags = context.flags()

    exporter.exportToImage(myAtlas,outputs_folder, 'tiff', image_settings)

def main():

    # Start a QGIS application without GUI
    qgs = QgsApplication([], False)
    qgs.initQgis()
    sys.path.append('/usr/share/qgis/python/plugins')

    qgs.initQgis()

    project_path = '/home/osm2igeotopo/X_PROJET_OSM2IGEOTOPO25.qgs'
    output_folder = '/home/osm2igeotopo/data_temp/dalles_export/'
    layout_name = 'EXPORT_DALLE'
    print('Starter atlas export')
    export_atlas(project_path, layout_name, output_folder)

    # Close the QGIS application
    qgs.exitQgis()

if __name__ == "__main__":
    main()
