export { containsMarriage, containsMarriageOrBezique, containsAnyTwoDifferent }
import { simulate } from './base.mjs'
import { fileURLToPath } from 'node:url'

function containsMarriage(hand) {
	return hand.find(c => c.rank === 'K') && hand.find(c => c.rank === 'Q')
}

function containsBezique(hand) {
	return hand.find(c => c.rank === 'J') && hand.find(c => c.rank === 'Q')
}

function containsKingAndJack(hand) {
	return hand.find(c => c.rank === 'K') && hand.find(c => c.rank === 'J')
}

function containsMarriageOrBezique(hand) {
	return containsMarriage(hand) || containsBezique(hand)
}

function containsAnyTwoDifferent(hand) {
	return containsMarriage(hand) ||
		containsBezique(hand) ||
		containsKingAndJack(hand)
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
	process.stdout.write('Marriage (K&Q): ')
	simulate(containsMarriage)

	process.stdout.write('Marriage or Bezique (K&Q | J&Q): ')
	simulate(containsMarriageOrBezique)

	process.stdout.write('Any two different faces: ')
	simulate(containsAnyTwoDifferent)
}
