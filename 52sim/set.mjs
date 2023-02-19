export default containsSet
import { simulate } from './base.mjs'
import { fileURLToPath } from 'node:url'

// returns the first set of n found
function containsSet(hand, n) {
	var ranks = {}
	for (var i = 0; i < hand.length; i++) {
		var r = hand[i].rank
		if (!ranks[r]) ranks[r] = []
		ranks[r].push(hand[i])
		if (ranks[r].length >= n) return ranks[r]
	}
	return false
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
	process.stdout.write('Pair: ')
	simulate(hand => containsSet(hand, 2))
	process.stdout.write('Three of a kind: ')
	simulate(hand => containsSet(hand, 3))
	process.stdout.write('Four of a kind: ')
	simulate(hand => containsSet(hand, 4))
}
