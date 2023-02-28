import test from 'node:test'
import assert from 'node:assert'
import { containsRun } from './run.mjs'

test('containsRun', async t => {
	await t.test('no aces run of 3', t => {
		var hand = [
			{ rank:6, suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:7, suit:'s' },
			{ rank:2, suit:'c' },
		]
		var expected = [
			{ rank:6, suit:'s' },
			{ rank:7, suit:'s' },
			{ rank:8, suit:'h' },
		]
		assert.deepStrictEqual(containsRun(hand, 3), expected)
	})
	await t.test('no aces, one short of run of 4', t => {
		var hand = [
			{ rank:6, suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:7, suit:'s' },
			{ rank:2, suit:'c' },
		]
		var expected = false
		assert.deepStrictEqual(containsRun(hand, 4), expected)
	})
	await t.test('aces low should not run with Q,K,A', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:'Q', suit:'s' },
			{ rank:2, suit:'c' },
		]
		var expected = false
		assert.deepStrictEqual(containsRun(hand, 3, true, false), expected)
	})
	await t.test('aces high should run with Q,K,A', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:'Q', suit:'s' },
			{ rank:2, suit:'c' },
		]
		var expected = [
			{ rank:'Q', suit:'s' },
			{ rank:'K', suit:'d' },
			{ rank:'A', suit:'s' },
		]
		assert.deepStrictEqual(containsRun(hand, 3, false, true), expected)
	})
	await t.test('aces high and low should wrap', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:'J', suit:'s' },
			{ rank:2, suit:'c' },
		]
		var expected = [
			{ rank:'K', suit:'d' },
			{ rank:'A', suit:'s' },
			{ rank:2, suit:'c' },
		]
		assert.deepStrictEqual(containsRun(hand, 3, true, true), expected)
	})
	await t.test('aces neither high nor low', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:3, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:'Q', suit:'s' },
			{ rank:2, suit:'c' },
		]
		var expected = false
		assert.deepStrictEqual(containsRun(hand, 3, false, false), expected)
	})
	await t.test('should work when run is > n', t => {
		var hand = [
			{ rank:9, suit:'s' },
			{ rank:3, suit:'h' },
			{ rank:'J', suit:'d' },
			{ rank:'Q', suit:'s' },
			{ rank:10, suit:'c' },
		]
		var expected = [
			{ rank:9, suit:'s' },
			{ rank:10, suit:'c' },
			{ rank:'J', suit:'d' },
		]

		assert.deepStrictEqual(containsRun(hand, 3), expected)
	})
})
