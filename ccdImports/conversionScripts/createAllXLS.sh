#!/usr/bin/env bash

set -eu

conversionFolder=$(dirname "$(readlink -f "$0")")
configFolder=${conversionFolder}/../configFiles

${conversionFolder}/convertJsonToXLS.sh ${configFolder}/CCD_Probate_Backoffice/
${conversionFolder}/convertJsonToXLS.sh ${configFolder}/CCD_Probate_Caveat/
${conversionFolder}/convertJsonToXLS.sh ${configFolder}/CCD_Probate_Legacy_Cases/
${conversionFolder}/convertJsonToXLS.sh ${configFolder}/CCD_Probate_Legacy_Search/
${conversionFolder}/convertJsonToXLS.sh ${configFolder}/CCD_Probate_Will_Lodgement/
${conversionFolder}/convertJsonToXLS.sh ${configFolder}/CCD_Probate_Standing_Search/
${conversionFolder}/convertJsonToXLS.sh ${configFolder}/CCD_Probate_BulkScanning_ExceptionRecord/

echo XLS files placed in /jsonToXLS folder
