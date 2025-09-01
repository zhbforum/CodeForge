import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OnbStep { welcome, reason, name }

@immutable
class OnboardingData {
  const OnboardingData({this.name, this.reasonCode});
  final String? name;
  final String? reasonCode;

  OnboardingData copyWith({String? name, String? reasonCode}) {
    return OnboardingData(
      name: name ?? this.name,
      reasonCode: reasonCode ?? this.reasonCode,
    );
  }
}

@immutable
class OnboardingState {
  const OnboardingState({required this.step, required this.data});
  final OnboardingData data;
  final OnbStep step;
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController()
    : super(
        const OnboardingState(step: OnbStep.welcome, data: OnboardingData()),
      );

  void goToReason() {
    state = OnboardingState(step: OnbStep.reason, data: state.data);
  }

  void chooseReason(String code) {
    state = OnboardingState(
      step: OnbStep.name,
      data: state.data.copyWith(reasonCode: code),
    );
  }

  void setName(String name) {
    state = OnboardingState(
      step: OnbStep.name,
      data: state.data.copyWith(name: name),
    );
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      return OnboardingController();
    });
