export default nSameSuit
import { simulate } from './base.mjs'
import { fileURLToPath } from 'node:url'

// returns the first n cards with the same suit, or false
function nSameSuit(hand, n) {
	const groups = {c:[], s:[], h:[], d:[]}
	for (var card of hand) {
		groups[card.suit].push(card)
		if (groups[card.suit].length >= n) return groups[card.suit]
	}
	return false
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
	process.stdout.write('2 of same suit: ')
	simulate(hand => nSameSuit(hand, 2))

	process.stdout.write('3 of same suit: ')
	simulate(hand => nSameSuit(hand, 3))

	process.stdout.write('4 of same suit: ')
	simulate(hand => nSameSuit(hand, 4))

	process.stdout.write('5 of same suit: ')
	simulate(hand => nSameSuit(hand, 5))

	process.stdout.write('6 of same suit (6 card hand): ')
	simulate(hand => nSameSuit(hand, 6), 6)
}
