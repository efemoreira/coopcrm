import '../../domain/entities/notificacao_entity.dart';

/// DTO de notificação persistida no log.
/// Mapeia a tabela `notifications_log` para [NotificacaoEntity].
class NotificacaoModel {
  final String id;
  final String userId;
  final String? cooperativeId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const NotificacaoModel({
    required this.id,
    required this.userId,
    this.cooperativeId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  factory NotificacaoModel.fromJson(Map<String, dynamic> json) {
    return NotificacaoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cooperativeId: json['cooperative_id'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'geral',
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificacaoEntity toEntity() => NotificacaoEntity(
    id: id,
    userId: userId,
    cooperativeId: cooperativeId,
    title: title,
    body: body,
    type: type,
    data: data,
    createdAt: createdAt,
  );
}
