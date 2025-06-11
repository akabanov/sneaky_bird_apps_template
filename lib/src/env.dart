// list them all here to minimise mistype-related bugs
class Env {
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const sentryDist = String.fromEnvironment('SENTRY_DIST');
  static const oneSignalAppId = String.fromEnvironment('ONESIGNAL_APP_ID');
}
