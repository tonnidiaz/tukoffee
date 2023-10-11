import 'package:flutter/material.dart';

class Store {
  final Address address;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final List<String> products;
  final List<TimeOfDay> times;
  const Store(
      {required this.address,
      required this.openTime,
      required this.closeTime,
      this.times = const [],
      this.products = const []});
}

class Address {
  final String? city;
  final String? street;
  final String? suburb;
  final int? postcode;
  final String? state;
  const Address(
      {this.street, this.suburb, this.city, this.postcode, this.state});
}
