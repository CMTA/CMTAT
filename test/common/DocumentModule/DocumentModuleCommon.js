const { expect } = require('chai');
const {  ZERO_ADDRESS } = require('../../utils')

function DocumentModuleCommon () {
  context('Document Module Test', function () {
    beforeEach(async function () {
      if ((await this.cmtat.documentEngine()) === ZERO_ADDRESS) {
        this.documentEngineMock = await ethers.deployContract("DocumentEngineMock")
        await this.cmtat.connect(this.admin).setDocumentEngine(this.documentEngineMock.target)
      }
    })
    it("testCanReturnTheRightAddressIfSet", async function (){
      if(this.definedAtDeployment){
        let documentEngine = await this.cmtat.documentEngine()
        expect(this.documentEngineMock.target).to.equal(documentEngine);
      }
    });
    it("testCanSetAndGetADocument", async function () {
      const name = ethers.encodeBytes32String("doc1");
      const uri = "https://github.com/CMTA/CMTAT";
      const documentHash = ethers.encodeBytes32String("hash1");
  
      await this.documentEngineMock.setDocument(name, uri, documentHash);
  
      const [storedUri, storedHash, lastModified] = await this.cmtat.getDocument(name);
      expect(storedUri).to.equal(uri);
      expect(storedHash).to.equal(documentHash);
      expect(lastModified).to.be.gt(0);
    });
  
    it("testCanUpdateADocument", async function () {
      const name = ethers.encodeBytes32String("doc1");
      const uri1 = "https://github.com/CMTA/CMTAT";
      const documentHash1 = ethers.encodeBytes32String("hash1");
  
      const uri2 = "https://github.com/CMTA/CMTAT/V2";
      const documentHash2 = ethers.encodeBytes32String("hash2");
  
      await this.documentEngineMock.setDocument(name, uri1, documentHash1);
      await this.documentEngineMock.setDocument(name, uri2, documentHash2);
  
      const [storedUri, storedHash, lastModified] = await this.cmtat.getDocument(name);
      expect(storedUri).to.equal(uri2);
      expect(storedHash).to.equal(documentHash2);
      expect(lastModified).to.be.gt(0);
    });

    it("testCanGetNullValueIfNoDocument", async function () {
      const name = ethers.encodeBytes32String("doc1");
      const [storedUri, storedHash, lastModified] = await this.cmtat.getDocument(name);
      expect(storedUri).to.equal("");
      expect(storedHash).to.equal(ethers.encodeBytes32String(""));
      expect(lastModified).to.equal(0);
    });
  
    it("testCanRemoveADocument", async function () {
      const name = ethers.encodeBytes32String("doc1");
      const uri = "https://github.com/CMTA/CMTAT";
      const documentHash = ethers.encodeBytes32String("hash1");
  
      await this.documentEngineMock.setDocument(name, uri, documentHash);
      await this.documentEngineMock.removeDocument(name);
      
      const [storedUri, storedHash, lastModified] = await this.cmtat.getDocument(name);
      expect(storedUri).to.equal("");
      expect(storedHash).to.equal(ethers.encodeBytes32String(""));
      expect(lastModified).to.equal(0);
    });
  
    it("testCanReturnAllDocumentNames", async function () {
      const name1 = ethers.encodeBytes32String("doc1");
      const uri1 = "https://github.com/CMTA/CMTAT";
      const documentHash1 = ethers.encodeBytes32String("hash1");
  
      const name2 = ethers.encodeBytes32String("doc2");
      const uri2 = "https://github.com/CMTA/CMTAT/V2";
      const documentHash2 = ethers.encodeBytes32String("hash2");
  
      await this.documentEngineMock.setDocument(name1, uri1, documentHash1);
      await this.documentEngineMock.setDocument(name2, uri2, documentHash2);
  
      const documentNames = await this.cmtat.getAllDocuments();
      expect(documentNames.length).to.equal(2);
      expect(documentNames).to.include(name1);
      expect(documentNames).to.include(name2);
    });
  
  })
}
module.exports = DocumentModuleCommon
