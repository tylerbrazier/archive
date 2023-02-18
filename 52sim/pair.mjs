export default containsPair
import { simulate } from './base.mjs'
import { fileURLToPath } from 'node:url'

// returns the first pair found
function containsPair(hand) {
	for (var i = 0; i < hand.length-1; i++)
		for (var j = i+1; j < hand.length; j++)
			if (hand[i].rank === hand[j].rank)
				return [ hand[i], hand[j] ]
	return false
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
	simulate(hand => containsPair(hand))
}
