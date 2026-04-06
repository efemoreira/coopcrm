import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa uma notificação persistida no log.
/// Diferente da notificação push local — esta é armazenada no banco e visível na tela de Notificações.
class NotificacaoEntity extends Equatable {
  final String id;
  final String userId;
  final String? cooperativeId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const NotificacaoEntity({
    required this.id,
    required this.userId,
    this.cooperativeId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, type, createdAt];
}
