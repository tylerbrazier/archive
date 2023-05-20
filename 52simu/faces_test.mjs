import test from 'node:test'
import assert from 'node:assert'
import {
	containsMarriage,
	containsMarriageOrBezique,
	containsAnyTwoDifferent
} from './faces.mjs'

test('faces', async t => {
	await t.test('does contain marriage', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(containsMarriage(hand))
	})
	await t.test('does not contain marriage', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'J', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(!containsMarriage(hand))
	})

	await t.test('containsMarriageOrBezique works for marriage', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(containsMarriageOrBezique(hand))
	})
	await t.test('containsMarriageOrBezique works for bezique', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'J', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(containsMarriageOrBezique(hand))
	})
	await t.test('containsMarriageOrBezique false if neither', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'Q', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(!containsMarriageOrBezique(hand))
	})

	await t.test('containsAnyTwoDifferent works for marriage', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'K', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(containsAnyTwoDifferent(hand))
	})
	await t.test('containsAnyTwoDifferent works for bezique', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'J', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(containsAnyTwoDifferent(hand))
	})
	await t.test('containsAnyTwoDifferent works for king and jack', t => {
		var hand = [
			{ rank:'J', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'J', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'K', suit:'c' },
		]
		assert(containsAnyTwoDifferent(hand))
	})
	await t.test('containsAnyTwoDifferent false if one face card', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'Q', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:7, suit:'c' },
		]
		assert(!containsAnyTwoDifferent(hand))
	})
	await t.test('containsAnyTwoDifferent false if same face card', t => {
		var hand = [
			{ rank:'A', suit:'s' },
			{ rank:8, suit:'h' },
			{ rank:'Q', suit:'d' },
			{ rank:8, suit:'s' },
			{ rank:'Q', suit:'c' },
		]
		assert(!containsAnyTwoDifferent(hand))
	})
})

