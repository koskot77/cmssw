#include "MiniDumper.h"
#include <string>
#include "FWCore/Utilities/interface/InputTag.h"

using namespace std;
using namespace edm;
using namespace reco;

MiniDumper::MiniDumper(const edm::ParameterSet& pset){
   genToken = consumes< vector<reco::GenParticle> >(edm::InputTag("prunedGenParticles","") );

}

void MiniDumper::beginRun(edm::Run const& iRun, edm::EventSetup const& iSetup){}

void MiniDumper::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup){

      edm::Handle< vector<reco::GenParticle> > __genParticles;
      iEvent.getByToken(genToken, __genParticles);  

    int num=0;
    if( __genParticles.isValid() ){
          for(vector<reco::GenParticle>::const_iterator p = __genParticles.product()->begin(); p != __genParticles.product()->end() && num<20; p++,num++){

        cout<<" gen "<<p->pdgId()<<" pT["<<num<<"] = "<<p->pt()<<" eta="<<p->eta()<<" phi="<<p->phi()<<" status="<<p->status()<<endl;
//              ParticlePointer particle( new Particle(p->energy(), p->px(), p->py(), p->pz()) );
//              particle->setXYZ   ( p->vx(), p->vy(), p->vz() );
//              particle->setName  ( LundCodesToNames::name(p->pdgId()) );
//              particle->setCharge( p->charge() );
//              particle->setPdgId ( p->pdgId()  );
//              particle->setStatus( p->status() );
          }
      }
}

#include "FWCore/PluginManager/interface/ModuleDef.h"
#include "FWCore/Framework/interface/MakerMacros.h"
#include "MuonAnalysis/MiniDumper/plugins/MiniDumper.h"

DEFINE_FWK_MODULE(MiniDumper);
