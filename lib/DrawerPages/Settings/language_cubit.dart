import 'package:why_taxi_user/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<Locale> {
  final String? locale;
  LanguageCubit(this.locale)
      : super(locale != null ? Locale(locale) : Locale('en'));

  void selectEngLanguage() {
    emit(Locale('en'));
  }

  void selectArabicLanguage() {
    emit(Locale('ar'));
  }

  void selectPortugueseLanguage() {
    emit(Locale('pt'));
  }

  void selectFrenchLanguage() {
    emit(Locale('fr'));
  }

  void selectIndonesianLanguage() {
    emit(Locale('id'));
  }

  void selectSpanishLanguage() {
    emit(Locale('es'));
  }
}
