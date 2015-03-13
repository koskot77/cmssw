import FWCore.ParameterSet.Config as cms

process = cms.Process("TriggerDumper")

process.load("FWCore.MessageLogger.MessageLogger_cfi")
process.MessageLogger.cout.placeholder = cms.untracked.bool(False)
process.MessageLogger.cout.threshold = cms.untracked.string('INFO')
process.MessageLogger.debugModules = cms.untracked.vstring('*')

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(100)
)

readFiles = cms.untracked.vstring()
process.source = cms.Source ("PoolSource", fileNames = readFiles)

# list of files
readFiles.extend([
        'file:/tmp/kkotov/MonotopToHad_S3_MSM-600_Tune4C_13TeV-madgraph-tauola.root'
] )

process.dumper= cms.EDAnalyzer("MiniDumper")

process.p = cms.Path(process.dumper)
