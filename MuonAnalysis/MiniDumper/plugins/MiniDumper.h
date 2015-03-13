#ifndef MiniDumper_h
#define MiniDumper_h

#include <memory>

#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/Event.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "DataFormats/HepMCCandidate/interface/GenParticle.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include <vector>

class MiniDumper : public edm::EDAnalyzer {
private:
        void beginRun(edm::Run const& iRun, edm::EventSetup const& iSetup);
	virtual void analyze(const edm::Event&, const edm::EventSetup&);

        edm::EDGetTokenT< std::vector<reco::GenParticle> > genToken;

public:
	explicit MiniDumper(const edm::ParameterSet&);
	~MiniDumper(void){}
};

#endif
