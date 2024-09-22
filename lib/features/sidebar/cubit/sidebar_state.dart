part of 'sidebar_cubit.dart';

final class SidebarState extends Equatable {
  const SidebarState({required this.isOpen, this.query = ''});

  final bool isOpen;
  final String query;

  @override
  List<Object> get props => [isOpen, query];
}
