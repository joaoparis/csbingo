class AppConfig {
  // Base URL for backend API (set via --dart-define=API_BASE_URL=https://api.example)
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://cs-bingo.onrender.com');

  // Optional frontend callback URL. When provided, the app will request the
  // backend to include this as the `redirect` query parameter so the backend
  // can redirect the browser back to the front-end callback with the token.
  // Set via --dart-define=FRONTEND_CALLBACK_URL=https://frontend.example.com/callback
  static const frontendCallbackUrl = String.fromEnvironment(
      'FRONTEND_CALLBACK_URL',
      defaultValue: 'https://csbingo-dbeda.web.app/callback');
}
