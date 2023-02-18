import { createDeck, shuffle, deal } from './deck.mjs'
import { format } from 'node:util'
import test from 'node:test'
import assert from 'node:assert'

// returns the first pair found
function containsPair(hand) {
	for (var i = 0; i < hand.length-1; i++)
		for (var j = i+1; j < hand.length; j++)
			if (hand[i].rank === hand[j].rank)
				return [ hand[i], hand[j] ]
	return false
}

// to run only this: node --test-only ...
test('probability hand contains pair', {only:true}, t => {
	const runCount = 100000
	var successCount = 0
	const handSize = 5
	for (var i = 0; i < runCount; i++) {
		const hand = deal(shuffle(createDeck()), handSize)
		var pair = containsPair(hand)
		if (pair) successCount++
	}
	t.diagnostic(format('success/total (%d/%d) = %d',
		successCount, runCount, successCount/runCount))
})

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
