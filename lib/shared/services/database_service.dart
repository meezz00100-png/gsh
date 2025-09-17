import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Generic method to insert data
  Future<List<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _supabase
          .from(table)
          .insert(data)
          .select();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to select data
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    String? where,
    dynamic whereValue,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = _supabase.from(table).select(columns);
      
      if (where != null && whereValue != null) {
        query = query.eq(where, whereValue);
      }
      
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final result = await query;
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to update data
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String where,
    required dynamic whereValue,
  }) async {
    try {
      final response = await _supabase
          .from(table)
          .update(data)
          .eq(where, whereValue)
          .select();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to delete data
  Future<void> delete({
    required String table,
    required String where,
    required dynamic whereValue,
  }) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq(where, whereValue);
    } catch (e) {
      rethrow;
    }
  }

  // Method to execute custom queries
  Future<List<Map<String, dynamic>>> customQuery({
    required String table,
    required Future<List<Map<String, dynamic>>> Function(PostgrestQueryBuilder) queryBuilder,
  }) async {
    try {
      final query = _supabase.from(table);
      return await queryBuilder(query);
    } catch (e) {
      rethrow;
    }
  }

  // Real-time subscription
  RealtimeChannel subscribeToTable({
    required String table,
    required void Function(PostgresChangePayload) onInsert,
    required void Function(PostgresChangePayload) onUpdate,
    required void Function(PostgresChangePayload) onDelete,
  }) {
    return _supabase
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: onUpdate,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: onDelete,
        )
        .subscribe();
  }

  // File upload to Supabase Storage
  Future<String> uploadFile({
    required String bucket,
    required String fileName,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    try {
      await _supabase.storage
          .from(bucket)
          .uploadBinary(fileName, Uint8List.fromList(fileBytes));
      
      return _supabase.storage
          .from(bucket)
          .getPublicUrl(fileName);
    } catch (e) {
      rethrow;
    }
  }

  // File download from Supabase Storage
  Future<List<int>> downloadFile({
    required String bucket,
    required String fileName,
  }) async {
    try {
      return await _supabase.storage
          .from(bucket)
          .download(fileName);
    } catch (e) {
      rethrow;
    }
  }

  // Delete file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String fileName,
  }) async {
    try {
      await _supabase.storage
          .from(bucket)
          .remove([fileName]);
    } catch (e) {
      rethrow;
    }
  }
}
