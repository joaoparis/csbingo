# BACKLOG 📋

----
## FEATURES TODO 💫
- [ ] FEATURE: add "player generation" cell topic (born between 95-2000 vs 90-95)
- [ ] FEATURE: game mode where the lines and colums earn more points OR the game end when the user gets one.

- SEE PHONE NOTES FROM QA TESTERS!!!!

- [ ] FEATURE: UI add backlight behind C4 toggle it according to game state...
- [ ] FEATURE: UI add "shock" visuals
- [ ] FEATURE: UI round players & flags images corners
- [ ] FEATURE: UI add "under development" notice

- [ ] FEATURE: points logic: 1 point per correct cell + the time it took to answer the cell
- [ ] FEATURE: add UI pop up when game ends showing the points! and maybe an explosion if the bomb was not desarmed?

- [ ] Update JSON with the latest CS Major Tournament

----
## FIXES TODO 🛠️
- [X] FIX: daily & random mode should not allow multiple taps
- [O] FIX: random mode points should only be visible at the end of the game 
- [ ] FIX: loading cell answer logic. it is loading the oposite way, sometimes... and it's not reaching the 100%...
- [ ] FIX: BE rm extra players' info from the GET /card response 

- [ ] FIX: Rive bug: cells red bkgd color should reset at the end of the game
- [ ] FIX: UI html: fix splash screen loading font
- [ ] FIX: big player names that don't fit the output UI should not be displayed with in a newline, instead make the text smaller or something...

----
#### FUTURE TOPICS 🔮
- [ ] save users with steam login / simple login
- [ ] add FFA mode: join lobby, select answers until the end, see result at the end
- [ ] add "generations" criteria to the games: a generation should be 5 years apart, so '95 to 2000 is one generation, 2000 to 2005 is another...
- [ ] BE deplloyment: improve loading game latency (takes too long to load game)
...
- [ ] Buy and set URL
- [ ] Add Google Ads



------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

# ROADMAP 🛣️
- [ ] MVP Ready (?)
- [ ] Share with friends
- [ ] Share on Reddit
- [ ] Share with streamers
- [ ] Add More Gameplays: FFA


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

## DONE ✅
- [x] FIX: delay when selecting cells ADDED LOADING 
- [x] FEATURE: suggested answers BE & FE
- [x] FEATURE: random game mode FE
- [x] FEATURE: loading screen message
- [x] FEATURE: add FFA message "in development.../ comming soon..."
- [x] FEATURE: UI make colors more real
- [x] FEATURE: UI improve toggle button with transparency
- [x] FEATURE: UI add exit option to toggle button
- [x] FIX: dialog boxes scroll and presentation in smaller screens (pop-up dialogs "cuts")
- [x] FIX: delay loading images
- [x] Load dumb images (or text for starters)
- [x] game state
- [x] add loading state to button (?)
- [x] timer
- [x] add round (players left) indicator screen add real skips indicators
- [x] add round (players left) indicator screen make points pretty
- [x] add round (players left) indicator screen fix skips logic
- [x] add round (players left) indicator screen add placeholder image
- [x] add round (players left) indicator screen add debug UI cell image text
- [x] add round (players left) indicator screen plumb with BE json
- [x] fix deployment script
- [x] fix last cell clicked when skips were clicked
- [x] check response with mock gateway response
- [x] call real BE for boards
- [x] send timeout action to BE
- [x] add visual wrong answer representation
- [x] call real BE to check cell clicks
- [x] add points logic
- [x] make skips pretty
- [x] make wires pretty
- [x] make c4 pretty (add tape details, c4 details, pcbs details)
- [X] add game type shifter UI: normal, ffa *** DO THIS NEXT *** shifter is there already, just need to import and use
- [X] study BE provider option: Panda API
- [X] add images to cells
- [x] create game information
- [x] fill "About" information with Project info
- [x] when requesting images from proxy, some images are not loaded -> implement retry mechanism (?) batch request (?) check proxy implementation
- [x] login with Steam OpenID
- [x] add login Steam button
- [x] BE deployment
- [x] UI update: During menu, add info about the game type, in the input display
- [x] UI update: Change loading to have a dedicated Rive animation in the Input Screen
- [x] UI update: remove "correct", "wrong" delay in animation
- [x] add end-game proposed solution (use switch to toggle solution vs answer)
- [x] UI update: fix trophies images
- [x] FEATURE: UI make cords on top smaller