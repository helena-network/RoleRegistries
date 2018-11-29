/* global artifacts contract beforeEach it assert web3 */
const { assertRevert } = require('./helpers/assertRevert')

const OwnedRegistryContract = artifacts.require('OwnedRegistry')
const MAXNUMCANDIDATES = 5
const ADMIN_ACCOUNT = web3.eth.accounts[0]
const NOT_ADMIN_ACCOUNT = web3.eth.accounts[1]
const TEST_ACCOUNT_1 = web3.eth.accounts[2]
const TEST_ACCOUNT_2 = web3.eth.accounts[3]

let Registry

contract('OwnedRegistry', function (accounts) {
  beforeEach(async () => {
    Registry = await OwnedRegistryContract.new(5, {from: ADMIN_ACCOUNT})
    await Registry.init()
    //await Registry.next()
  })
  describe('Whitelisting accounts', async () => {
    it('Should whiteList an account if it is required by the owner', async () => {
      await Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT})
	  console.log("STATE: "+ JSON.stringify(await Registry._debug()))
	   await Registry.next()
       let isWhitelisted = await Registry.isWhitelisted.call(TEST_ACCOUNT_1)
       assert.strictEqual(true, isWhitelisted)
    })
  })
  //   it('Should NOT whitelist an account if it is required by an account different than the owner', async () => {
  //     await assertRevert(Registry.whiteList(TEST_ACCOUNT_1, {from: NOT_ADMIN_ACCOUNT}))
  //   })
  //   it('Should increase the registry index after whitelisting an account ', async () => {
  //     let initialIndex = await Registry.listingCounter.call()
  //     await Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT})
  //     let updatedNumberOfListings = await Registry.listingCounter.call()
  //     assert.equal(initialIndex.toNumber() + 1, updatedNumberOfListings.toNumber())
  //   })
  //   it('Should increase the listing Counter counter N times before the MAX is reached', async () => {
  //     let initialNumberOfListings = await Registry.listingCounter.call()
  //     let i = 0
  //     while (i < MAXNUMCANDIDATES) {
  //       await Registry.whiteList(TEST_ACCOUNT_1 + i, {from: ADMIN_ACCOUNT})
  //       i++
  //     }
  //     let updatedNumberOfListings = await Registry.listingCounter.call()
  //     assert.equal(initialNumberOfListings.toNumber() + MAXNUMCANDIDATES, updatedNumberOfListings.toNumber())
  //   })
  //   it('Should throw if the candidate is added twice', async () => {
  //     await Registry.whiteList(TEST_ACCOUNT_1)
  //     await assertRevert(Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT}))
  //   })
  //   it('Should throw if a candidate is added and the list is full', async () => {
  //     await Registry.setMaxNumListings(MAXNUMCANDIDATES)
  //     let initialNumberOfListings = await Registry.listingCounter.call()
  //     let i = 0
  //     while (i < MAXNUMCANDIDATES) {
  //       await Registry.whiteList(TEST_ACCOUNT_1 + i, {from: ADMIN_ACCOUNT})
  //       i++
  //     }
  //     let updatedNumberOfListings = await Registry.listingCounter.call()
  //     await assertRevert(Registry.whiteList(TEST_ACCOUNT_1 + MAXNUMCANDIDATES + 1))
  //   })
  // })
  // describe('Changing the maxNumListings', async () => {
  //   it('Should be set by default to the maximum number', async () => {
  //     const maxNumberSol = Math.pow(2, 256) - 1
  //     const maxNumListings = await Registry.maxNumListings.call()
  //     assert.strictEqual(maxNumberSol, maxNumListings.toNumber())
  //   })
  //   it('Should change the maximum number of listings if the listingCounter is less than the expected value', async () => {
  //     await Registry.setMaxNumListings(MAXNUMCANDIDATES)
  //     const newMaxNumListings = await Registry.maxNumListings.call()
  //     assert.strictEqual(MAXNUMCANDIDATES, newMaxNumListings.toNumber())
  //   })
  //   it('Should throw when it is tried to change the maximum number of listings if the listing counter is higher than the expected value', async () => {
  //     let i = 0
  //     while (i < MAXNUMCANDIDATES) {
  //       await Registry.whiteList(TEST_ACCOUNT_1 + i, {from: ADMIN_ACCOUNT})
  //       i++
  //     }
  //     const updatedNumberOfListings = await Registry.listingCounter.call()
  //     assert.strictEqual(MAXNUMCANDIDATES, updatedNumberOfListings.toNumber())
  //     await Registry.setMaxNumListings(MAXNUMCANDIDATES)
  //     const newMaxNumListings = await Registry.maxNumListings.call()
  //     assert.strictEqual(MAXNUMCANDIDATES, newMaxNumListings.toNumber())
  //     assertRevert(Registry.setMaxNumListings(MAXNUMCANDIDATES - 1))
  //   })
  // })
  // describe('Removing listings', async () => {
  //   it('Should remove a candidate if it is required by the owner', async () => {
  //     await Registry.whiteList(TEST_ACCOUNT_1)
  //     await Registry.remove(TEST_ACCOUNT_1)
  //     let isInTheList = await Registry.isWhitelisted.call(TEST_ACCOUNT_1)
  //     assert.strictEqual(false, isInTheList)
  //   })
  //   it('Should NOT remove an account if it is required by an account different than the owner', async () => {
  //     await assertRevert(Registry.remove(TEST_ACCOUNT_1, {from: NOT_ADMIN_ACCOUNT}))
  //   })
  //   it('Should decrease the listing counter after removing a listing ', async () => {
  //     let initialNumberOfListings = await Registry.listingCounter.call()
  //     await Registry.whiteList(TEST_ACCOUNT_1)
  //     await Registry.remove(TEST_ACCOUNT_1)
  //     let updatedNumberOfListings = await Registry.listingCounter.call()
  //     assert.equal(initialNumberOfListings.toNumber(), updatedNumberOfListings.toNumber())
  //   })
  // })
  // describe('Adding an application', async () => {
  //   it('Should add an application', async () => {
  //     const data = 'Application'
  //     const bytesID = '0x01'
  //     await Registry.apply(bytesID, 0, data)
  //     const returnData = await Registry.applicationData.call('0x01')
  //     assert.strictEqual(data, returnData)
  //   })
  //   it('Should initialize an application as not approved', async () => {
  //     const data = 'Application'
  //     const bytesID = '0x01'
  //     await Registry.apply(bytesID, 0, data)
  //     const approved = await Registry.applicationIsApproved.call('0x01')
  //     assert.strictEqual(false, approved)
  //   })
  // })
})
