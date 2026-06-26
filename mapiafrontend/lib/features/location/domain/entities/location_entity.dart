class AppLocationEntity {
  const AppLocationEntity({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;
}
