import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({
    required this.pdfPath,
    required this.title,
    super.key,
  });

  final String pdfPath;
  final String title;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // PDFファイルの存在確認
      final file = File(widget.pdfPath);
      // ファイルの存在確認を同期的に行う
      if (!file.existsSync()) {
        setState(() {
          _errorMessage = 'PDFファイルが見つかりません';
          _isLoading = false;
        });
        return;
      }

      // ファイルサイズチェック（例：10MB以下）
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        setState(() {
          _errorMessage = 'ファイルサイズが大きすぎます（10MB以下にしてください）';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'PDFの読み込みに失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('PDFを読み込んでいます...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('戻る'),
            ),
          ],
        ),
      );
    }

    // 実際のPDFビューアー実装
    // 注意: flutter_pdfviewやpdf_render_webなどの
    // PDF表示ライブラリを使用することを推奨
    return _buildPdfPlaceholder(theme);
  }

  Widget _buildPdfPlaceholder(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // PDFファイル情報カード
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.pdfPath.split('/').last,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ファイルパス: ${widget.pdfPath}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // アクションボタン
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _openWithExternalApp,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('外部アプリで開く'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _copyPath,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('ファイルパスをコピー'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // PDF表示ライブラリについての案内
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF表示機能について',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'より高度なPDF表示機能を利用するには、flutter_pdfviewや'
                  'pdf_renderなどのライブラリを追加してください。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sharePdf() {
    // PDF共有機能の実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF共有機能（実装予定）')),
    );
  }

  void _openWithExternalApp() {
    // 外部アプリでPDFを開く
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('外部アプリで開く機能（実装予定）')),
    );
  }

  void _copyPath() {
    // ファイルパスをクリップボードにコピー
    Clipboard.setData(ClipboardData(text: widget.pdfPath));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ファイルパスをコピーしました')),
    );
  }
}
