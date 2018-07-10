const { assertRevert } = require('./helpers/assertRevert')

const OwnedRegistryFactoryContract = artifacts.require('OwnedRegistryFactory')
let RegistryFactoryInstance;
const MAXNUMCANDIDATES = 5
const ADMIN_ACCOUNT = web3.eth.accounts[0]
const NOT_ADMIN_ACCOUNT = web3.eth.accounts[1]
const TEST_ACCOUNT = web3.eth.accounts[2]

let Registry

contract('OwnedRegistryFactory', function (accounts) {
  beforeEach(async () => {
    RegistryFactoryInstance = await OwnedRegistryFactoryContract.new(5, {from: ADMIN_ACCOUNT})
  })
  describe('Creating Registries', async () => {
    it('Should return an address after creating a new Registry', async () => {
        const label = 'voter'
        await RegistryFactoryInstance.newRegistry(label);
        const address = await RegistryFactoryInstance.getRegistry.call(label);
        return assert.lengthOf(address, 42)
    })
  })
})
