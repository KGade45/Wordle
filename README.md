# Wordle iOS

A simple iOS version of the popular Wordle game, built in Swift with UIKit. Guess the hidden word in 6 tries and get instant feedback through colored tiles.


https://github.com/user-attachments/assets/dd433601-3f08-4113-b5c5-721405c1301b

### Key Features
- Word guessing with up to 6 attempts
- Color-changing tiles:
  - Green → correct letter & position 🟩
  - Yellow → correct letter, wrong position 🟨
  - Gray → letter not in word ◻️
- Clean, minimal UIKit-based interface

### Technical Details
- UIKit + Swift for UI and interactions
- Game logic to validate guesses and provide feedback
- Lightweight structure: models for words, views for tiles, and a main controller managing gameplay
