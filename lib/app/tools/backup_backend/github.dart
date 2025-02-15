import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:github/github.dart';

import 'package:chaldea/models/userdata/local_settings.dart';
import 'package:chaldea/utils/utils.dart';
import 'backend.dart';

extension _GithubSettingX on GithubSetting {
  RepositorySlug get slug => RepositorySlug(owner, repo);
}

class GithubBackup<T> extends BackupBackend<T> {
  final GithubSetting config;
  GitHub github = GitHub();
  final FutureOr<List<int>> Function() encode;
  final FutureOr<T> Function(List<int> data) decode;

  GithubBackup({required this.config, required this.encode, required this.decode});

  @override
  Future<bool> backup({String? message}) async {
    github.auth = Authentication.withToken(config.token);
    final content = base64Encode(await encode());
    if (message == null || message.isEmpty) {
      message = DateTime.now().toStringShort(omitSec: false);
    }
    // print('content: $content');
    print('message: $message');
    final sha = config.sha ??= (await _getFile())?.sha;
    print('using sha: $sha');
    final creation = await _updateFile(content: content, message: message, sha: sha);
    if (creation.content?.sha == null) {
      throw GitHubError(github, 'Failed to create file, no sha found');
    }
    config.sha = creation.content!.sha!;
    print('new sha: ${config.sha}');
    return true;
  }

  @override
  Future<T?> restore() async {
    github.auth = Authentication.withToken(config.token);
    final file = await _getFile();
    if (file == null) throw NotFound(github, 'NotFound');
    if (file.encoding == 'base64') {
      final result = decode(base64Decode(LineSplitter.split(file.content!).join()));
      config.sha = file.sha;
      return result;
    }
    if (file.encoding == 'none' && file.size != null && file.size! > 0) {
      return decode(await _getRawFile());
    }
    throw UnknownError(github, 'Unknown encoding: ${file.encoding}');
  }

  Dio _createDio() {
    final d = DioE(
      BaseOptions(
        baseUrl: 'https://api.github.com',
        headers: {
          'Accept': 'application/vnd.github+json',
          if (config.token.isNotEmpty) 'Authorization': 'Bearer ${config.token}',
          if (!kIsWeb) 'User-Agent': 'chaldea/2.0',
          "X-GitHub-Api-Version": "2022-11-28",
        },
      ),
    );
    return d;
  }

  Future<List<int>> _getRawFile() async {
    final resp = await _createDio().get(
      '/repos/${config.slug}/contents/${config.path}?buster=${DateTime.now().timestamp}',
      options: Options(headers: {'Accept': 'application/vnd.github.raw+json'}, responseType: ResponseType.bytes),
      queryParameters: {if (config.branch.isNotEmpty) 'ref': config.branch},
    );
    return List.from(resp.data);
  }

  Future<GitHubFile?> _getFile() async {
    try {
      final response = await _createDio().get(
        '/repos/${config.slug}/contents/${config.path}?buster=${DateTime.now().timestamp}',
        queryParameters: {if (config.branch.isNotEmpty) 'ref': config.branch},
      );
      if (response.data is List) {
        throw GitHubError(github, 'Path is a directory');
      }
      return GitHubFile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        throw GitHubError(github, e.response!.data['message']);
      }
      rethrow;
    }
  }

  Future<ContentCreation> _updateFile({required String content, required String message, String? sha}) async {
    try {
      final response = await _createDio().put(
        '/repos/${config.slug}/contents/${config.path}',
        data: <String, dynamic>{
          'message': message,
          'content': content,
          if (config.branch.trim().isNotEmpty) 'branch': config.branch,
          if (sha != null) 'sha': sha,
        },
      );
      return ContentCreation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictError(github, e.response!.data['message']);
      }
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        throw GitHubError(github, e.response!.data['message']);
      }
      rethrow;
    }
  }
}

class ConflictError extends GitHubError {
  ConflictError(super.github, super.message);
}
