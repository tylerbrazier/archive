import { simulate } from './base.mjs'
import test from 'node:test'
import assert from 'node:assert'

// returns the first n cards with the same suit, or false
function nSameSuit(hand, n) {
	const groups = {c:[], s:[], h:[], d:[]}
	for (var card of hand) {
		groups[card.suit].push(card)
		if (groups[card.suit].length >= n) return groups[card.suit]
	}
	return false
}

test('probability of same suit', {only:true}, async t => {
	await t.test('2 of same suit', t => {
		t.diagnostic(simulate(hand => nSameSuit(hand, 2)))
	})
	await t.test('3 of same suit', t => {
		t.diagnostic(simulate(hand => nSameSuit(hand, 3)))
	})
	await t.test('4 of same suit', t => {
		t.diagnostic(simulate(hand => nSameSuit(hand, 4)))
	})
	await t.test('5 of same suit', t => {
		t.diagnostic(simulate(hand => nSameSuit(hand, 5)))
	})
})

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
