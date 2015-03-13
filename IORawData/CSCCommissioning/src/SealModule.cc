#include "FWCore/PluginManager/interface/ModuleDef.h"
#include "CSCFileReader.h"
#include <IORawData/DaqSource/interface/DaqReaderPluginFactory.h>
DEFINE_SEAL_MODULE();
DEFINE_EDM_PLUGIN(DaqReaderPluginFactory, CSCFileReader, "CSCFileReader");

#include "CSCFileDumper.h"
#include "FWCore/Framework/interface/MakerMacros.h"
DEFINE_ANOTHER_FWK_MODULE(CSCFileDumper);

