import { nSameSuit, containsEverySuit } from './suits.mjs'
import test from 'node:test'
import assert from 'node:assert'

test('nSameSuit', async t => {
	await t.test('has equal to n (3)', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'s' },
			{ rank:8, suit:'d' },
			{ rank:10, suit:'c' },
			{ rank:10, suit:'s' },
		]
		var expected = [
			{ rank:'A', suit:'s' },
			{ rank:'K', suit:'s' },
			{ rank:10, suit:'s' },
		]
		assert.deepStrictEqual(nSameSuit(hand, 3), expected)
	})
	await t.test('has less than n', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'s' },
			{ rank:8, suit:'d' },
			{ rank:10, suit:'c' },
			{ rank:10, suit:'d' },
		]
		assert.deepStrictEqual(nSameSuit(hand, 3), false)
	})
	await t.test('has more than n', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'s' },
			{ rank:8, suit:'s' },
			{ rank:10, suit:'c' },
			{ rank:10, suit:'s' },
		]
		var expected = [
			{ rank:'A', suit:'s' },
			{ rank:'K', suit:'s' },
			{ rank:8, suit:'s' },
		]
		assert.deepStrictEqual(nSameSuit(hand, 3), expected)
	})
})

test('containsEverySuit', async t => {
	await t.test('true when hand does have', t => {
		var hand = [
			{ rank:'A', suit:'d' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'s' },
			{ rank:8, suit:'s' },
			{ rank:10, suit:'c' },
		]
		assert(containsEverySuit(hand))
	})
	await t.test('false when hand does not have', t => {
		var hand = [
			{ rank:'A', suit:'c' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'s' },
			{ rank:8, suit:'s' },
			{ rank:10, suit:'c' },
		]
		assert(!containsEverySuit(hand))
	})
})
