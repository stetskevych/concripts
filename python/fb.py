"""
Facebook logo stickers cost $2 each from the company store. I have an idea. I want to cut up the stickers, and use the letters to make other words/phrases. A Facebook logo sticker contains only the word 'facebook', in all lower-case letters.

Write a function that, given a string consisting of a word or words made up of letters from the word 'facebook', outputs an integer with the number of stickers I will need to buy. foo('coffee kebab') -> 3 foo('book') -> 1 foo('ffacebook') -> 2

You can assume the input you are passed is valid, that is, does not contain any non-'facebook' letters, and the only potential non-letter characters in the string are spaces.

"""

import math
import unittest

def facebook(string):
    strLen = len(string)
    counts = {}
    maxCount = 0
    example = 'facebook'

    for i in range(strLen):
        char = string[i]

        if char not in example:
            if char == ' ':
                continue
            else:
                raise ValueError(f'Found bad character {char} at index {i} in the provided string. Only characters'
                             f' in the word "{example}" are accepted.')

        # could use defaultdict instead
        if char not in counts:
            counts[char] = 0

        if char == 'o':
            counts[char] += 0.5
        else:
            counts[char] += 1

#        currentCount = math.ceil(counts[char])
#        if currentCount > maxCount:
#            maxCount = currentCount

#    maxIndex = max(counts, key=counts.get)
#    maxCount = math.ceil(counts[maxIndex])

    maxCount = math.ceil(max(counts.values()))

    return maxCount

class FacebookTest(unittest.TestCase):
    def test_fb_one(self):
        self.assertEqual(facebook('book'), 1)

    def test_fb_two(self):
        self.assertEqual(facebook('ffacebook'), 2)

    def test_fb_three_with_spaces(self):
        self.assertEqual(facebook('coffee kebab'), 3)

    def test_fb_invalid(self):
        with self.assertRaises(ValueError):
            facebook('invalid string')

if __name__ == '__main__':
#    n = facebook('fooooofacebook')
#    print(n)
    unittest.main()
