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

      // these are the expected accounts after the movements carried out before
      const expectedAccounts = [[TEST_ACCOUNT_1, TEST_ACCOUNT_2], [TEST_ACCOUNT_2], []]
      await Registry.next()

      const actualAccounts = []
      // the actual accounts are the return value from the function which allows to read the values
      // the cleanArray function removes the address(0)... addresses which are returned. The address(0) addresses
      // are retured because the array is a fixed size address array, which means all non-filled positions will
      // have the address(0) address
      actualAccounts[0] = cleanArray(await Registry.debug_getArchive(1))
      actualAccounts[1] = cleanArray(await Registry.debug_getArchive(2))
      actualAccounts[2] = cleanArray(await Registry.debug_getArchive(3))

      // this verifies the arrays contain the same addresses
      // it was possible to make a more complex array verification check but it would
      // just take too much time, and the effect would be the same.
      assert.equal(JSON.stringify(actualAccounts[0]), JSON.stringify(expectedAccounts[0]))
      assert.equal(JSON.stringify(actualAccounts[1]), JSON.stringify(expectedAccounts[1]))
      assert.equal(JSON.stringify(actualAccounts[2]), JSON.stringify(expectedAccounts[2]))

      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_1, 1), true, 'Test account 1 incorrect for Epoch 1, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_2, 1), true, 'Test account 2 incorrect for Epoch 1, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_1, 2), false, 'Test account 1 incorrect for Epoch 2, should be false')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_2, 2), true, 'Test account 2 incorrect for Epoch 2, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_2, 3), false, 'Test account 2 incorrect for Epoch 3, should be false')
    })
  })
  describe('Overriding functions', async () => {
    it('Should correctly add current period and add to the archive', async () => {
      // initially there should be 0 listings
      assert.equal(await Registry.listingCounter(), 0)

      await Registry.whitelistCurrentPeriod(TEST_ACCOUNT_1)
      assert.equal(await Registry.listingCounter(), 1)
      // user should be whitelisted
      assert.equal(await Registry.isWhitelisted(TEST_ACCOUNT_1), true)

      // Should revert because it was already added to next epoch in last transaction
      await assertRevert(Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT}))

      await Registry.next()
      await Registry.whitelistCurrentPeriod(TEST_ACCOUNT_2)

      await Registry.next()
      await Registry.debug_forceUpdate()

      // let r0 = await Registry.debug_getArchiveAndPeriod(1)
      // console.log('0 --> P: ' + r0[0] + 'Add: ' + r0[1])

      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_1, 0), true, 'Test account 1 incorrect for Epoch 1, should be true')

      // // Should maintain the address added in the previous period
      // assert.equal(await Registry.listingCounter(), 1)
    })

    it('Should be able to use the both functions (add to current and next periods) at the same time', async () => {
      // initially there should be 0 listings
      const startStage = 0
      assert.equal(await Registry.listingCounter(), startStage)

      await Registry.whitelistCurrentPeriod(TEST_ACCOUNT_1)
      await Registry.whiteList(TEST_ACCOUNT_2, {from: ADMIN_ACCOUNT})
      await Registry.whiteList(TEST_ACCOUNT_3, {from: ADMIN_ACCOUNT})
      // should be 1 before updating
      assert.equal(await Registry.listingCounter(), 1)

      await Registry.next()
      // Should be 3 after updating
      assert.equal(await Registry.listingCounter(), 3)

      await Registry.debug_forceUpdate()
      await Registry.next()
      await Registry.debug_forceUpdate()

      // debug
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_1, startStage), true, 'Test account 1 incorrect for Epoch 0, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_2, startStage + 1), true, 'Test account 2 incorrect for Epoch 1, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_3, startStage + 1), true, 'Test account 3 incorrect for Epoch 1, should be true')

      await Registry.next()
      await Registry.debug_forceUpdate()

      const expectedWhitelistedFromPeriod0 =
        [ TEST_ACCOUNT_1,
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000' ]

      const actualWhitelistedFromPeriod0 = await Registry.getWhitelistedFromEpoch(0)
      assert.equal(JSON.stringify(actualWhitelistedFromPeriod0), JSON.stringify(expectedWhitelistedFromPeriod0))
    })

    it('Should revert when user is already whitlisted on current period', async () => {
      // initially there should be 0 listings
      assert.equal(await Registry.listingCounter(), 0)
      await Registry.whiteList(TEST_ACCOUNT_1, {from: ADMIN_ACCOUNT})
      await Registry.next()
      assert.equal(await Registry.listingCounter(), 1)
      await assertRevert(Registry.whitelistCurrentPeriod(TEST_ACCOUNT_1))
    })
    it('Should correctly remove from the current period', async () => {
      const startStage = 0
      assert.equal(await Registry.listingCounter(), 0)

      await Registry.whitelistCurrentPeriod(TEST_ACCOUNT_1)
      assert.equal(await Registry.isWhitelisted(TEST_ACCOUNT_1), true)
      assert.equal(await Registry.listingCounter(), 1)

      await Registry.blacklistCurrentPeriod(TEST_ACCOUNT_1)
      assert.equal(await Registry.listingCounter(), 0)
      assert.equal(await Registry.isWhitelisted(TEST_ACCOUNT_1), false)
    })

    it('Should correctly update the Archive when removing from the current period', async () => {
      const startStage = 0
      assert.equal(await Registry.listingCounter(), 0)

      await Registry.whitelistCurrentPeriod(TEST_ACCOUNT_1)
      await Registry.whitelistCurrentPeriod(TEST_ACCOUNT_2)
      assert.equal(await Registry.isWhitelisted(TEST_ACCOUNT_1), true)
      assert.equal(await Registry.isWhitelisted(TEST_ACCOUNT_2), true)
      assert.equal(await Registry.listingCounter(), 2)

      await Registry.next()

      await Registry.blacklistCurrentPeriod(TEST_ACCOUNT_2)
      assert.equal(await Registry.listingCounter(), 1)
      assert.equal(await Registry.isWhitelisted(TEST_ACCOUNT_2), false)

      await Registry.debug_forceUpdate()
      await Registry.next()
      await Registry.debug_forceUpdate()

      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_1, startStage), true, 'Test account 1 incorrect for Epoch 0, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_2, startStage), true, 'Test account 1 incorrect for Epoch 0, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_1, startStage + 1), true, 'Test account 2 incorrect for Epoch 1, should be true')
      assert.equal(await Registry.wasWhitelisted(TEST_ACCOUNT_2, startStage + 1), false, 'Test account 2 incorrect for Epoch 1, should be false')
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
