export default containsSets
import { simulate } from './base.mjs'
import { fileURLToPath } from 'node:url'

// returns the first n sets of size s
function containsSets(hand, s, n=1) {
	var ranks = {}
	var result = []
	for (var i = 0; i < hand.length; i++) {
		var r = hand[i].rank
		if (!ranks[r]) ranks[r] = []
		ranks[r].push(hand[i])
		if (ranks[r].length >= s) {
			result.push(ranks[r])
			result = result.flat()
			if (result.length === s*n)
				return result
		}
	}
	return false
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
	process.stdout.write('Pair: ')
	simulate(hand => containsSets(hand, 2))
	process.stdout.write('Three of a kind: ')
	simulate(hand => containsSets(hand, 3))
	process.stdout.write('Four of a kind: ')
	simulate(hand => containsSets(hand, 4))

	process.stdout.write('Two Pair: ')
	simulate(hand => containsSets(hand, 2, 2))
	process.stdout.write('Three Pair (6 card hand): ')
	simulate(hand => containsSets(hand, 2, 3), 6)
	process.stdout.write('Four Pair (8 card hand): ')
	simulate(hand => containsSets(hand, 2, 3), 8)
}
