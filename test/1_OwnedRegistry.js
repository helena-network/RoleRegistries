/* global artifacts contract beforeEach it assert web3 */
const { assertRevert } = require('./helpers/assertRevert')
// var _ = require('underscore')

const OwnedRegistryContract = artifacts.require('OwnedRegistryMock')
const MAXNUMCANDIDATES = 5
const ADMIN_ACCOUNT = web3.eth.accounts[0]
const NOT_ADMIN_ACCOUNT = web3.eth.accounts[1]
const TEST_ACCOUNT_1 = web3.eth.accounts[2]
const TEST_ACCOUNT_2 = web3.eth.accounts[3]
const TEST_ACCOUNT_3 = web3.eth.accounts[4]
const TEST_ACCOUNT_4 = web3.eth.accounts[5]

const MOCK_TRL_ADDRESS = web3.eth.accounts[6]

let Registry

contract('OwnedRegistry', function (accounts) {
  beforeEach(async () => {
    Registry = await OwnedRegistryContract.new({from: ADMIN_ACCOUNT})
    await Registry.init(5, 5, MOCK_TRL_ADDRESS)
  })
  describe('Whitelisting accounts', async () => {
    it('Should whiteList an account if it is required by the owner', async () => {
      await Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT})

      await Registry.next()
      let isWhitelisted = await Registry.isWhitelisted.call(TEST_ACCOUNT_1)
      assert.strictEqual(true, isWhitelisted)
    })
  })
  it('Should NOT whitelist an account if it is required by an account different than the owner', async () => {
    await assertRevert(Registry.whiteList(TEST_ACCOUNT_1, {from: NOT_ADMIN_ACCOUNT}))
  })
  it('Should increase the registry index after whitelisting an account ', async () => {
    let initialIndex = await Registry.listingCounter()
    await Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT})
    await Registry.next()
    let updatedNumberOfListings = await Registry.listingCounter()
    assert.equal(updatedNumberOfListings.toNumber(), initialIndex.toNumber() + 1)
  })
  it('Should increase the listing Counter counter N times before the MAX is reached', async () => {
    let initialNumberOfListings = await Registry.listingCounter()
    let i = 0
    while (i < MAXNUMCANDIDATES) {
      await Registry.whiteList(TEST_ACCOUNT_1 + i, {from: ADMIN_ACCOUNT})
      i++
    }
    await Registry.next()
    let updatedNumberOfListings = await Registry.listingCounter()
    assert.equal(updatedNumberOfListings.toNumber(), initialNumberOfListings.toNumber() + MAXNUMCANDIDATES)
  })
  it('Should throw if the candidate is added twice', async () => {
    await Registry.whiteList(TEST_ACCOUNT_1)
    await assertRevert(Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT}))
  })
  it('Should throw if a candidate is added and the list is full', async () => {
    await Registry.setMaxNumListings(MAXNUMCANDIDATES)
    let initialNumberOfListings = await Registry.listingCounter()
    let i = 0
    while (i < MAXNUMCANDIDATES) {
      await Registry.whiteList(TEST_ACCOUNT_1 + i, {from: ADMIN_ACCOUNT})
      i++
    }
    let updatedNumberOfListings = await Registry.listingCounter()
    await assertRevert(Registry.whiteList(TEST_ACCOUNT_1 + MAXNUMCANDIDATES + 1))
  })

  describe('Changing the maxNumListings', async () => {
    it('Should be set by default to the maximum number', async () => {
      const maxNumberSol = MAXNUMCANDIDATES
      const maxNumListings = await Registry.maxNumListings()
      assert.strictEqual(maxNumberSol, maxNumListings.toNumber())
    })
    it('Should change the maximum number of listings if the listingCounter is less than the expected value', async () => {
      await Registry.setMaxNumListings(MAXNUMCANDIDATES)
      await Registry.next()
      const newMaxNumListings = await Registry.maxNumListings()
      assert.strictEqual(MAXNUMCANDIDATES, newMaxNumListings.toNumber())
    })
    it('Should throw when it is tried to change the maximum number of listings if the listing counter is higher than the expected value', async () => {
      let i = 0
      while (i < MAXNUMCANDIDATES) {
        await Registry.whiteList(TEST_ACCOUNT_1 + i, {from: ADMIN_ACCOUNT})
        i++
      }
      await Registry.next()
      const updatedNumberOfListings = await Registry.listingCounter()
      assert.strictEqual(MAXNUMCANDIDATES, updatedNumberOfListings.toNumber())
      await Registry.setMaxNumListings(MAXNUMCANDIDATES)
      await Registry.next()
      const newMaxNumListings = await Registry.maxNumListings()
      assert.strictEqual(MAXNUMCANDIDATES, newMaxNumListings.toNumber())
      assertRevert(Registry.setMaxNumListings(MAXNUMCANDIDATES - 1))
    })
  })

  describe('Removing listings', async () => {
    it('Should remove a candidate if it is required by the owner', async () => {
      await Registry.whiteList(TEST_ACCOUNT_1)
      await Registry.remove(TEST_ACCOUNT_1)
      await Registry.next()
      let isInTheList = await Registry.isWhitelisted.call(TEST_ACCOUNT_1)
      assert.strictEqual(false, isInTheList)
    })
    it('Should NOT remove an account if it is required by an account different than the owner', async () => {
      await assertRevert(Registry.remove(TEST_ACCOUNT_1, {from: NOT_ADMIN_ACCOUNT}))
    })
    it('Should decrease the listing counter after removing a listing ', async () => {
      let initialNumberOfListings = await Registry.listingCounter()
      await Registry.whiteList(TEST_ACCOUNT_1)
      await Registry.remove(TEST_ACCOUNT_1)
      await Registry.next()
      let updatedNumberOfListings = await Registry.listingCounter()
      assert.equal(initialNumberOfListings.toNumber(), updatedNumberOfListings.toNumber())
    })
  })

  describe('End to end test', async () => {
    it('Should achieve a correct state after a bunch of changes', async () => {
      // initially there should be 0 listings
      assert.equal(await Registry.listingCounter(), 0)

      await Registry.whiteList(TEST_ACCOUNT_1)
      await Registry.whiteList(TEST_ACCOUNT_2)
      // should still be zero, because we havent moved to the next period
      assert.equal(await Registry.listingCounter(), 0)
      // moving period
      await Registry.next()
      // Should be 2, because we've moved period and the counter should have been updated
      assert.equal(await Registry.listingCounter(), 2)
      // counter should continue droping as we remove more accounts
      await Registry.remove(TEST_ACCOUNT_1)
      await Registry.next()
      assert.equal(await Registry.listingCounter(), 1)

      await Registry.remove(TEST_ACCOUNT_2)
      await Registry.next()
      assert.equal(await Registry.listingCounter(), 0)

      // Trying to remove a non existing account should fail
      await assertRevert(Registry.remove(TEST_ACCOUNT_2, {from: ADMIN_ACCOUNT}))

      await Registry.whiteList(TEST_ACCOUNT_2, {from: ADMIN_ACCOUNT})
      // Trying to whitelist an already existing account should fail
      await assertRevert(Registry.whiteList(TEST_ACCOUNT_2, {from: ADMIN_ACCOUNT}))

      const expectedAccounts = [[TEST_ACCOUNT_1, TEST_ACCOUNT_2], [TEST_ACCOUNT_2], []]

      const actualAccounts = []

      actualAccounts[0] = cleanArray(await Registry.debug_getArchive(0))
      actualAccounts[1] = cleanArray(await Registry.debug_getArchive(1))
      actualAccounts[2] = cleanArray(await Registry.debug_getArchive(2))

      assert.equal(JSON.stringify(actualAccounts[0]), JSON.stringify(expectedAccounts[0]))
      assert.equal(JSON.stringify(actualAccounts[1]), JSON.stringify(expectedAccounts[1]))
      assert.equal(JSON.stringify(actualAccounts[2]), JSON.stringify(expectedAccounts[2]))
    })
  })
})

function cleanArray (arr) {
  let cleaned = []
  for (let element of arr) {
    if (element.indexOf('0x000000000') > -1) {
      continue
    }
    cleaned.push(element)
  }
  return cleaned
}
