TODO LIST:

1. Also randomize weapons (what would be the best solution for that?)
2. Show the item bought for about a sec? With a transitioning animation (before sending to the inventory)
3. Integrate with the modLoader
4. Organize files (as soon as I learn how to make functions static and public to other classes - move everything to the randomizer_service) 
5. Add main screen logo
6. Add description text to categories shown
7. Add mod version to main screen

KNOWN BUGS:
1. Lootboxes are broken
2. Not 100% confirmed but check the garanteed weapon preference in the first 6 waves

ADD DIFFERENT MODES:
1. Only random items
2. Random weapons as well - shop categories based on weapon set
3. ??? (idk name) - Shop only offers items; get a random weapon at the beginning of each wave (more % of weapon type you already own - if 6 weapons then they start to upgrade at the end of each wave. chance to upgraded version of weapons incl.)
4. All random - shop only offers the '?' category

KNOWN PLACES TO CHANGE
1. create a new ItemParentData and override the get_effects_text() for the categories (easiest way)