enum DiagnosticPhase {
  idle,
  measuringIdlePing,
  measuringDownload,
  measuringUpload,
  complete,
  failed,
}

enum ConnectionHealth { excellent, fair, poor, degraded, unknown }

class NetworkDiagnosticResult {
  final DateTime testedAt;
  final double idlePingMs;
  final double downloadMbps;
  final double downloadPingMs;
  final double uploadMbps;
  final double uploadPingMs;
  final double jitterMs;
  final double packetLossPercent;

  const NetworkDiagnosticResult({
    required this.testedAt,
    required this.idlePingMs,
    required this.downloadMbps,
    required this.downloadPingMs,
    required this.uploadMbps,
    required this.uploadPingMs,
    this.jitterMs = 0,
    this.packetLossPercent = 0,
  });

  double get averagePingMs => (idlePingMs + downloadPingMs + uploadPingMs) / 3;

  ConnectionHealth get health => classifyConnectionHealth(
        downloadMbps: downloadMbps,
        uploadMbps: uploadMbps,
        averagePingMs: averagePingMs,
        packetLossPercent: packetLossPercent,
      );
}

ConnectionHealth classifyConnectionHealth({
  required double downloadMbps,
  required double uploadMbps,
  required double averagePingMs,
  required double packetLossPercent,
}) {
  if (packetLossPercent >= 10 || averagePingMs >= 400) {
    return ConnectionHealth.degraded;
  }
  final speed = downloadMbps < uploadMbps ? downloadMbps : uploadMbps;
  if (speed > 10) return ConnectionHealth.excellent;
  if (speed >= 2) return ConnectionHealth.fair;
  return ConnectionHealth.poor;
}

extension ConnectionHealthLabel on ConnectionHealth {
  String get label => switch (this) {
        ConnectionHealth.excellent => 'Excellent',
        ConnectionHealth.fair => 'Fair',
        ConnectionHealth.poor => 'Poor',
        ConnectionHealth.degraded => 'Degraded',
        ConnectionHealth.unknown => 'Awaiting test',
      };

  String get description => switch (this) {
        ConnectionHealth.excellent => 'High-resolution multimedia is enabled.',
        ConnectionHealth.fair => 'HD media stays on, with a lighter buffer.',
        ConnectionHealth.poor => 'Lightweight placeholders replace rich media.',
        ConnectionHealth.degraded => 'Connection is unstable. Placeholders are active.',
        ConnectionHealth.unknown => 'Run a diagnostic to classify this connection.',
      };
}
