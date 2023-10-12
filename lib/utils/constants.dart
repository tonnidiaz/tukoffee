// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/views/about.dart';
import 'package:frust/views/account/index.dart';
import 'package:frust/views/account/profile.dart';
import 'package:frust/views/account/settings.dart';
import 'package:frust/views/admin/orders.dart';
import 'package:frust/views/auth/create.dart';
import 'package:frust/views/auth/login.dart';
import 'package:frust/views/auth/reset_pass.dart';
import 'package:frust/views/cart.dart';
import 'package:frust/views/root/index.dart';
import 'package:frust/views/map.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/views/order/checkout.dart';
import 'package:frust/views/order/payment.dart';
import 'package:frust/views/product.dart';
import 'package:frust/views/rf.dart';
import 'package:frust/views/search.dart';
import 'package:geocode/geocode.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../views/admin/dashboard.dart';
import '../views/admin/settings.dart';
import '../views/app/settings.dart';
import '../views/home.dart';
import '../views/rf2.dart';
import '../views/shop/index.dart';

enum SortBy { name, price, dateCreated, lastModified }

enum SortOrder { ascending, descending }

enum OrderStatus { pending, delivered, cancelled, all }

class TuPage {
  Widget widget;
  bool inList;
  bool isAction;
  String name;
  IconData? icon;
  Widget? ic;
  String label;
  TuPage(this.name, this.widget,
      {this.icon,
      this.inList = true,
      this.isAction = false,
      this.label = '',
      this.ic});
}

final List<TuPage> pages = [
  TuPage(
    "/shop",
    const ShopPage(),
    icon: CupertinoIcons.home,
  ),
  TuPage(
    "/",
    const IndexPage(),
    icon: CupertinoIcons.home,
  ),
  TuPage(
    "/map",
    const MapPage(),
    icon: CupertinoIcons.map,
  ),
  TuPage(
    "/product",
    const ProductPage(),
    icon: CupertinoIcons.home,
  ),
  TuPage(
    "/rf",
    const RFPage(),
    icon: CupertinoIcons.home,
  ),
  TuPage(
    "/rf2",
    const RFPage2(),
    icon: CupertinoIcons.home,
  ),
  TuPage(
    "/search",
    const SearchPage(),
    icon: CupertinoIcons.search,
  ),
  TuPage(
    "/admin/dashboard",
    const DashboardPage(),
    icon: CupertinoIcons.home,
  ),
  TuPage(
    "/dashboard",
    const DashboardPage(),
    icon: CupertinoIcons.home,
  ),
  TuPage("/app/settings", const SettingsPage(),
      icon: CupertinoIcons.info_circle, inList: false),
  TuPage("/auth/login", LoginPage(), icon: CupertinoIcons.home, inList: false),
  TuPage("/auth/resetPass", const ResetPassPage(),
      icon: CupertinoIcons.home, inList: false),
  TuPage("/admin/settings", const AdminSettingsPage(),
      icon: CupertinoIcons.home, inList: false),
  TuPage("/auth/create", const SignupPage(),
      icon: CupertinoIcons.home, inList: false),
  TuPage("/orders", const OrdersPage(),
      icon: CupertinoIcons.home, inList: false),
  TuPage("/admin/orders", const OrdersPage(),
      icon: CupertinoIcons.home, inList: false),
  TuPage("/cart", const CartPage(), icon: CupertinoIcons.home, inList: false),
  TuPage("/order/checkout", const CheckoutPage(),
      icon: CupertinoIcons.home, inList: false),
  TuPage("/order", const OrderPage(), icon: CupertinoIcons.home, inList: false),
  TuPage("/order/checkout/payment", const PaymentPage(),
      icon: CupertinoIcons.home, inList: false),
  TuPage("/about", const AboutPage(),
      icon: CupertinoIcons.info_circle, isAction: true),
  TuPage("/account", const AccountPage(),
      icon: CupertinoIcons.info_circle, isAction: true),
  TuPage("/account/profile", const ProfilePage(),
      icon: CupertinoIcons.info_circle, isAction: true),
  TuPage("/account/settings", const AccountSettingsPage(),
      icon: CupertinoIcons.info_circle, isAction: true),
];

const String tag = "Tunedbass";
const String package = "com.tb.tmeta";
const double bottomSheetH = 150;
const double bottomBarH = 46;
const double footerH = 46;
const double appBarH = 56;
const double tabH = 46;
double statusBarH(BuildContext context) {
  return MediaQuery.of(context).viewPadding.top;
}

const double sidebarW = 46;
const double iconSize = 25;
const double splashRadius = iconSize;
const testUser = {"email": "tonni@gmail.com", "password": "Baseline@072"};
Box<dynamic>? appBox;
const bool isMobile = true;
final dio = Dio();
const localhost = "http://172.16.10.204";
const String apiURL = false ? "https://tukoffee.vercel.app" : "$localhost:8000";
const defaultPadding = EdgeInsets.all(6);
const defaultPadding2 = EdgeInsets.all(14);
Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

Size screenPercent(BuildContext context, double p) {
  final h = MediaQuery.of(context).size.height;
  final w = MediaQuery.of(context).size.width;
  final pw = (p / 100) * w;
  final ph = (p / 100) * h;
  return Size(pw, ph);
}

double keyboardPadding(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom;
}

final defaultMenu = [
  MenuItemButton(
    onPressed: () {
      clog("Open clicked");
    },
    shortcut: const SingleActivator(LogicalKeyboardKey.keyO, control: true),
    child: const Text("Open"),
  ),
  MenuItemButton(
    onPressed: () {
      clog("Open clicked");
    },
    shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
    child: const Text("Save"),
  ),
];

class SelectItem {
  final String label;
  final dynamic value;
  SelectItem(this.label, this.value);
}

Map<String, dynamic> styles = {
  "h1": const TextStyle(
      fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
};

const paystackSecretKeyDemo =
    "sk_test_7c31366f091fd9bddfc2126935832309c7525f18";
const paystackSecretKey = "sk_live_8e1e2765c345025d2261662f71d284f61ebac80f";
const paystackPayUrl = "https://paystack.com/pay";
var paystackDio = Dio(
  BaseOptions(
    headers: {
      "Authorization": 'Bearer $paystackSecretKeyDemo',
    },
    contentType: "application/json",
    baseUrl: "https://api.paystack.co",
  ),
);
Dio apiDio() => Dio(BaseOptions(
    baseUrl: apiURL,
    contentType: "application/json",
    headers: appBox!.get("authToken") != null
        ? {"Authorization": "Bearer ${appBox!.get("authToken")}"}
        : {}));

Map<String, dynamic> dummyGeocodeRes = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "datasource": {
          "sourcename": "openstreetmap",
          "attribution": "© OpenStreetMap contributors",
          "license": "Open Database License",
          "url": "https://www.openstreetmap.org/copyright"
        },
        "name": "Davies Street",
        "country": "South Africa",
        "country_code": "za",
        "state": "Gauteng",
        "county": "City of Johannesburg Metropolitan Municipality",
        "city": "Johannesburg",
        "municipality": "City of Johannesburg Metropolitan Municipality",
        "postcode": "2001",
        "suburb": "Doornfontein",
        "street": "Davies Street",
        "lon": 28.0534776,
        "lat": -26.1974939,
        "state_code": "GT",
        "distance": 12838367.61645573,
        "formatted":
            "Davies Street, Doornfontein, Johannesburg, 2001, South Africa",
        "address_line1": "Davies Street",
        "address_line2": "Doornfontein, Johannesburg, 2001, South Africa",
        "timezone": {
          "name": "Africa/Johannesburg",
          "offset_STD": "+02:00",
          "offset_STD_seconds": 7200,
          "offset_DST": "+02:00",
          "offset_DST_seconds": 7200,
          "abbreviation_STD": "SAST",
          "abbreviation_DST": "SAST"
        },
        "plus_code": "5G5CR333+29",
        "plus_code_short":
            "33+29 Johannesburg, City of Johannesburg Metropolitan Municipality, South Africa",
        "result_type": "street",
        "rank": {
          "importance": 0.3250025,
          "popularity": 5.430417100375699,
          "confidence": 0.5,
          "confidence_city_level": 1,
          "confidence_street_level": 1,
          "match_type": "match_by_street"
        },
        "place_id":
            "518e113fb5b00d3c4059d5a8d1f58e323ac0f00102f901c0aa490200000000c0020492030d44617669657320537472656574"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [28.0534776, -26.1974939]
      },
      "bbox": [28.0534776, -26.1989361, 28.0538185, -26.1974939]
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [28.057857, -26.193954]
      },
      "properties": {
        "country_code": "za",
        "name": "Doornfontein",
        "country": "South Africa",
        "county": "Johannesburg",
        "datasource": {
          "sourcename": "whosonfirst",
          "url": "https://www.whosonfirst.org/docs/licenses/"
        },
        "state": "Gauteng",
        "suburb": "Doornfontein",
        "lon": 28.057857,
        "lat": -26.193954,
        "state_code": "GT",
        "city": "Johannesburg",
        "postcode": "2001",
        "distance": 12838501.343702799,
        "formatted": "Doornfontein, Johannesburg, GT, South Africa",
        "address_line1": "Doornfontein",
        "address_line2": "Johannesburg, GT, South Africa",
        "timezone": {
          "name": "Africa/Johannesburg",
          "offset_STD": "+02:00",
          "offset_STD_seconds": 7200,
          "offset_DST": "+02:00",
          "offset_DST_seconds": 7200,
          "abbreviation_STD": "SAST",
          "abbreviation_DST": "SAST"
        },
        "plus_code": "5G5CR345+C4",
        "plus_code_short": "45+C4 Johannesburg, South Africa",
        "result_type": "suburb",
        "rank": {
          "popularity": 4.6417867070895475,
          "confidence": 0.25,
          "confidence_city_level": 1,
          "match_type": "match_by_city_or_disrict"
        },
        "place_id":
            "513cd862b7cf0e3c4059abed26f8a6313ac0c0020592030c446f6f726e666f6e7465696ee2032377686f736f6e66697273743a6e65696768626f7572686f6f643a343230373832393935"
      },
      "bbox": [28.0528568429, -26.1989541323, 28.0628568429, -26.1889541323]
    },
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [27.52502, -24.88018]
      },
      "properties": {
        "country_code": "za",
        "country": "South Africa",
        "county": "Waterberg",
        "datasource": {
          "sourcename": "whosonfirst",
          "url": "https://www.whosonfirst.org/docs/licenses/"
        },
        "state": "Limpopo",
        "district": "Thabazimbi",
        "city": "Doornfontein",
        "lon": 27.52502,
        "lat": -24.88018,
        "state_code": "LP",
        "distance": 12710692.773957869,
        "formatted": "Doornfontein, Waterberg, South Africa",
        "address_line1": "Doornfontein",
        "address_line2": "Waterberg, South Africa",
        "timezone": {
          "name": "Africa/Johannesburg",
          "offset_STD": "+02:00",
          "offset_STD_seconds": 7200,
          "offset_DST": "+02:00",
          "offset_DST_seconds": 7200,
          "abbreviation_STD": "SAST",
          "abbreviation_DST": "SAST"
        },
        "plus_code": "5G794G9G+W2",
        "result_type": "city",
        "rank": {
          "popularity": 0.5291431604611457,
          "confidence": 0.25,
          "confidence_city_level": 1,
          "match_type": "match_by_city_or_disrict"
        },
        "place_id":
            "51f5bef1b567863b4059e197fa7953e138c0c00208e2031f77686f736f6e66697273743a6c6f63616c6974793a31333433353435353137"
      },
      "bbox": [27.50502, -24.90018, 27.54502, -24.86018]
    }
  ],
  "query": {
    "text": "50 Davies street Doornfontein",
    "parsed": {
      "housenumber": "50",
      "street": "davies street",
      "suburb": "doornfontein",
      "expected_type": "building"
    }
  }
};

final geocode = GeoCode(apiKey: "238584900778579231059x68104");
