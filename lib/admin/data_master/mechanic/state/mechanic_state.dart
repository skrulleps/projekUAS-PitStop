import '../model/mechanic_model.dart';

class MechanicState {
  final List<MechanicModel> mechanics;
  final bool isLoading;

  MechanicState({
    required this.mechanics,
    required this.isLoading,
  });

  factory MechanicState.initial() {
    return MechanicState(
      mechanics: [],
      isLoading: true,
    );
  }

  MechanicState copyWith({
    List<MechanicModel>? mechanics,
    bool? isLoading,
  }) {
    return MechanicState(
      mechanics: mechanics ?? this.mechanics,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
