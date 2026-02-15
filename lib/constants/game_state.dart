enum OldGameState {
  Idle,
  Loading,
  Playing,
  GameOver,
  FFALobby,
}

// --------------------------------

enum OrchestratorState {
  menu,
  loading,
  playing,
  gameOver,
}

enum OrchestratorEvents {
  selectOption,
  startGame,
  gameOver,
  returnToMenu,
}

enum MenuState {
  dailyGame,
  randomGame,
  ffaGame,
  inactive,
}

enum MenuEvent {
  toggleOption,
  selectOption,
}

enum GameState {
  loading,
  playing,
  verifyingAnswer,
  gameOver,
  error,
  inactive,
}

enum GameEvent {
  startGame,
  tapCell,
  roundEvaluated,
  nextRound,
  skipRound,
  timeUp,
  gameOver,
}

enum GameOverState {
  displayingPlayerAnswers,
  displayingSuggestedAnswers,
}

enum GameOverEvent {
  toggleOption,
}
