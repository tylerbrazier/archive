import test from 'node:test'
import assert from 'node:assert'
import containsSets from './set.mjs'

test('containsSets', async t => {
	await t.test('non-adjacent pair', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:10, suit:'c' },
		]
		var expected = [
			{ rank:8, suit:'h' },
			{ rank:8, suit:'s' },
		]
		assert.deepStrictEqual(containsSets(hand, 2), expected)
	})
	await t.test('finds last 2 card pair', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:10, suit:'s' },
			{ rank:10, suit:'c' },
		]
		var expected = [
			{ rank:10, suit:'s' },
			{ rank:10, suit:'c' },
		]
		assert.deepStrictEqual(containsSets(hand, 2), expected)
	})
	await t.test('finds pair in hand w/ three of a kind', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'K', suit:'c' },
		]
		var expected = [
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
		]
		assert.deepStrictEqual(containsSets(hand, 2), expected)
	})
	await t.test('false when no pair', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:9, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		var expected = false
		assert.strictEqual(containsSets(hand, 2), expected)
	})
	await t.test('finds three of a kind', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'K', suit:'c' },
		]
		var expected = [
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:'K', suit:'c' },
		]
		assert.deepStrictEqual(containsSets(hand, 3), expected)
	})
	await t.test('false when hand contains pair but not 3 of a kind', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:10, suit:'c' },
		]
		var expected = false
		assert.deepStrictEqual(containsSets(hand, 3), expected)
	})

	await t.test('contains 2 pair', t => {
		var hand = [
			{ rank:10, suit:'s' },
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:10, suit:'c' },
		]
		var expected = [
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:10, suit:'s' },
			{ rank:10, suit:'c' },
		]
		assert.deepStrictEqual(containsSets(hand, 2, 2), expected)
	})
	await t.test('does not contain 2 pair', t => {
		var hand = [
			{ rank:9, suit:'s' },
			{ rank:'K', suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:10, suit:'c' },
		]
		var expected = false
		assert.deepStrictEqual(containsSets(hand, 2, 2), expected)
	})
})
