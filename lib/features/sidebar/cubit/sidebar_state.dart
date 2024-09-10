part of 'sidebar_cubit.dart';

final class SidebarState extends Equatable {
  const SidebarState({required this.isOpen});

  final bool isOpen;

  @override
  List<Object> get props => [isOpen];
}
