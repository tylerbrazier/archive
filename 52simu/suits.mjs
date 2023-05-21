export { nSameSuit, nDifferentSuits }
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

function nDifferentSuits(hand, n) {
	if (!n) throw Error('no n')
	const suits = {c:false, s:false, h:false, d:false}
	for (var card of hand) suits[card.suit] = true
	return (Object.values(suits).filter(v => v).length >= n)
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
	// process.stdout.write('2 of same suit: ')
	// simulate(hand => nSameSuit(hand, 2))

	// process.stdout.write('3 of same suit: ')
	// simulate(hand => nSameSuit(hand, 3))

	// process.stdout.write('4 of same suit: ')
	// simulate(hand => nSameSuit(hand, 4))

	// process.stdout.write('5 of same suit: ')
	// simulate(hand => nSameSuit(hand, 5))

	// process.stdout.write('6 of same suit (6 card hand): ')
	// simulate(hand => nSameSuit(hand, 6), 6)

	process.stdout.write('5 card hand contains every suit: ')
	simulate(hand => nDifferentSuits(hand, 4), 5)

	process.stdout.write('5 card hand contains 3 different suits: ')
	simulate(hand => nDifferentSuits(hand, 3), 5)
}
