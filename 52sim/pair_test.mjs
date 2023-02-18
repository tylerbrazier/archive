import test from 'node:test'
import assert from 'node:assert'
import containsPair from './pair.mjs'

test('containsPair', async t => {
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
		assert.deepStrictEqual(containsPair(hand), expected)
	})
	await t.test('finds last 2 cards', t => {
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
		assert.deepStrictEqual(containsPair(hand), expected)
	})
	await t.test('works with three of a kind', t => {
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
		assert.deepStrictEqual(containsPair(hand), expected)
	})
	await t.test('false when no pair', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:9, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert.strictEqual(containsPair(hand), false)
	})
})
