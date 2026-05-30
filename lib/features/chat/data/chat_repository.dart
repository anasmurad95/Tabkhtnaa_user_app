import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_response.dart';

class ChatRepository {
  ChatRepository(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> listConversations() async {
    final res = await _client.dio.get('/conversations/list');
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status) {
      throw ApiException(parsed.errorMsg ?? 'Failed to load conversations');
    }
    final payload = parsed.data;
    if (payload is List) return payload.cast<Map<String, dynamic>>();
    if (parsed.raw != null && parsed.raw!['data'] is List) {
      return (parsed.raw!['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<({Map<String, dynamic> conversation, List<Map<String, dynamic>> messages})> getConversation(
    int conversationId,
  ) async {
    final res = await _client.dio.get('/conversations/get', queryParameters: {
      'conversation_id': conversationId,
    });
    final parsed = ApiResponse.fromJson(res.data as Map<String, dynamic>);
    if (!parsed.status || parsed.data == null) {
      throw ApiException(parsed.errorMsg ?? 'Failed to load conversation');
    }
    final root = parsed.data as Map<String, dynamic>;
    final conversation = (root['conversation'] as Map<String, dynamic>?) ?? root;
    final messagesRaw = root['data'];
    final messages = messagesRaw is List ? messagesRaw.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    return (conversation: conversation, messages: messages);
  }

  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    final res = await _client.dio.post('/conversations/send_message', data: {
      'conversation_id': conversationId,
      'message': message,
    });
    return _unwrap(res.data);
  }

  Future<Map<String, dynamic>> createConversation({
    required int user2Id,
    required String user2Type,
    int? orderId,
    String? message,
  }) async {
    final res = await _client.dio.post('/conversations/create', data: {
      'user2_id': user2Id,
      'user2_type': user2Type,
      if (orderId != null) 'order_id': orderId,
      if (message != null) 'message': message,
    });
    return _unwrap(res.data);
  }

  Map<String, dynamic> _unwrap(dynamic raw) {
    final parsed = ApiResponse.fromJson(raw as Map<String, dynamic>);
    if (!parsed.status || parsed.data == null) {
      throw ApiException(parsed.errorMsg ?? 'Chat request failed');
    }
    return parsed.data as Map<String, dynamic>;
  }
}
