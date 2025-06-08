// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:flutter/material.dart';

class AppConstant {
  static const String APP_NAME = "Bricool App";

  static const String USER_PASSWORD = "user_password_halal_food_app";
  static const String USER_EMAIL = "user_email_halal_food_app";

  // api
  //static const String BASE_FILE = "http://127.0.0.1:8000";
  //static const String BASE_FILE = "https://drbynz00.pythonanywhere.com";
  static const String BASE_FILE = "https://optionally-willing-raven.ngrok-free.app";

  static const String BASE_URL = "$BASE_FILE/api/";


  static const String USER_URI = "users/";
  static const String SELLER_URI = "sellers/";
  static const String TOKEN_URI = "token/";
  static const String LOGIN_URI = "login-view/";
  static const String PASSWORD_RESET = "password_reset/";
  static const String VERIFY_PASSWORD = "password_reset/verify/";
  static const String SAVE_PASSWORD = "password_reset/save/";
  static const String CHANGE_PASSWORD = "password_change/";
  static const String BANNER_URI = "banners/";
  static const String STORE_URI = "stores/";
  static const String SECTION_URI = "sections/";
  static const String PRODUCT_URI = "products/";
  static const String CATEGORIE_URI = "categories/";
  static const String CARD_URI = "cards/";
  static const String INTERNAL_ORDER_URI = "internal-orders/";
  static const String EXTERNAL_ORDER_URI = "external-orders/";
  static const String FACTURE_CLIENT_URI = "factures/clients/";
  static const String FACTURE_FOURNISSEUR_URI = "factures/fournisseurs/";
  static const String CUSTOMER_URI = "customers/";
  static const String SUPPLIER_URI = "suppliers/";
  static const String DISCOUNT_URI = "discounts/";
  static const String DELIVERY_NOTE_URI = "delivery-notes/";
  static const String HISTORICAL_URI = "historical/";
  static const String DEFAULT_PRODUCT_IMAGE =
      "https://img.freepik.com/premium-photo/flat-shopping-bag-with-percentage-sign-vector-concept-as-vector-shopping-bag-with-percentage_980716-664374.jpg?w=2000";

  //Couleurs
  static const Color PRIMARY_COLOR = Color.fromARGB(255, 12, 107, 185);
  static const Color APPBAR_COLOR = Color(0xFF003366);
  static const Color NAME_COLOR = Color(0xFF004A99);
  static const Color TEXT_COLOR = Color(0xFF333333);
}
