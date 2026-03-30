import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../modules/financial/data/models/transaction_model.dart';

class ExportService {
  static Future<String> exportToPdf(
    List<TransactionModel> transactions,
    double totalIncome,
    double totalExpense,
    double balance,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Relatório Financeiro',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Equily Assistente',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          _buildSummarySection(
            totalIncome,
            totalExpense,
            balance,
            currencyFormat,
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Detalhamento das Transações',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          _buildTransactionsTable(transactions, dateFormat, currencyFormat),
          pw.SizedBox(height: 24),
          _buildCategorySummary(transactions, currencyFormat),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'relatorio_equily_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.Widget _buildSummarySection(
    double totalIncome,
    double totalExpense,
    double balance,
    NumberFormat currencyFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Receitas',
            currencyFormat.format(totalIncome),
            PdfColors.green,
          ),
          _buildSummaryItem(
            'Despesas',
            currencyFormat.format(totalExpense),
            PdfColors.red,
          ),
          _buildSummaryItem(
            'Saldo',
            currencyFormat.format(balance),
            PdfColors.blue,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    String value,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTransactionsTable(
    List<TransactionModel> transactions,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeader('Data'),
            _tableHeader('Descrição'),
            _tableHeader('Categoria'),
            _tableHeader('Valor'),
          ],
        ),
        ...transactions.map(
          (t) => pw.TableRow(
            children: [
              _tableCell(dateFormat.format(t.date)),
              _tableCell(t.title),
              _tableCell(_getCategoryName(t.category)),
              _tableCell(
                currencyFormat.format(t.amount),
                align: pw.TextAlign.right,
                color: t.type == TransactionTypeModel.income
                    ? PdfColors.green
                    : PdfColors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    pw.TextAlign? align,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 9, color: color),
      ),
    );
  }

  static pw.Widget _buildCategorySummary(
    List<TransactionModel> transactions,
    NumberFormat currencyFormat,
  ) {
    final categoryTotals = <TransactionCategoryModel, double>{};
    for (var t in transactions.where(
      (t) => t.type == TransactionTypeModel.expense,
    )) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumo por Categoria',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        ...categoryTotals.entries.map(
          (e) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(_getCategoryName(e.key)),
                pw.Text(
                  currencyFormat.format(e.value),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _getCategoryName(TransactionCategoryModel category) {
    switch (category) {
      case TransactionCategoryModel.salary:
        return 'Salário';
      case TransactionCategoryModel.investment:
        return 'Investimento';
      case TransactionCategoryModel.food:
        return 'Alimentação';
      case TransactionCategoryModel.transport:
        return 'Transporte';
      case TransactionCategoryModel.entertainment:
        return 'Entretenimento';
      case TransactionCategoryModel.health:
        return 'Saúde';
      case TransactionCategoryModel.education:
        return 'Educação';
      case TransactionCategoryModel.shopping:
        return 'Compras';
      case TransactionCategoryModel.bills:
        return 'Contas';
      case TransactionCategoryModel.other:
        return 'Outros';
    }
  }

  static Future<String> exportToCsv(
    List<TransactionModel> transactions,
    double totalIncome,
    double totalExpense,
    double balance,
  ) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final List<List<dynamic>> rows = [
      ['RELATÓRIO FINANCEIRO - EQUILY'],
      [
        'Data de Exportação',
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      ],
      [],
      ['RESUMO'],
      ['Receitas', currencyFormat.format(totalIncome)],
      ['Despesas', currencyFormat.format(totalExpense)],
      ['Saldo', currencyFormat.format(balance)],
      [],
      ['DETALHAMENTO DAS TRANSAÇÕES'],
      ['Data', 'Descrição', 'Categoria', 'Tipo', 'Valor', 'Conta', 'Parcela'],
    ];

    for (var t in transactions) {
      rows.add([
        dateFormat.format(t.date),
        t.title,
        _getCategoryName(t.category),
        t.type == TransactionTypeModel.income ? 'Receita' : 'Despesa',
        currencyFormat.format(t.amount),
        t.accountId ?? '-',
        t.isInstallment ? '${t.installmentCurrent}/${t.installmentTotal}' : '-',
      ]);
    }

    rows.add([]);
    rows.add(['RESUMO POR CATEGORIA']);
    rows.add(['Categoria', 'Total']);

    final categoryTotals = <TransactionCategoryModel, double>{};
    for (var t in transactions.where(
      (t) => t.type == TransactionTypeModel.expense,
    )) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    for (var entry in categoryTotals.entries) {
      rows.add([
        _getCategoryName(entry.key),
        currencyFormat.format(entry.value),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'relatorio_equily_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${output.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }

  static Future<String> exportToExcel(
    List<TransactionModel> transactions,
    double totalIncome,
    double totalExpense,
    double balance,
  ) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final List<List<dynamic>> rows = [
      ['RELATÓRIO FINANCEIRO - EQUILY'],
      [
        'Data de Exportação',
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      ],
      [],
      ['RESUMO'],
      ['Receitas', totalIncome],
      ['Despesas', totalExpense],
      ['Saldo', balance],
      [],
      ['DETALHAMENTO DAS TRANSAÇÕES'],
      ['Data', 'Descrição', 'Categoria', 'Tipo', 'Valor', 'Conta', 'Parcela'],
    ];

    for (var t in transactions) {
      rows.add([
        dateFormat.format(t.date),
        t.title,
        _getCategoryName(t.category),
        t.type == TransactionTypeModel.income ? 'Receita' : 'Despesa',
        t.amount,
        t.accountId ?? '-',
        t.isInstallment ? '${t.installmentCurrent}/${t.installmentTotal}' : '-',
      ]);
    }

    rows.add([]);
    rows.add(['RESUMO POR CATEGORIA']);
    rows.add(['Categoria', 'Total']);

    final categoryTotals = <TransactionCategoryModel, double>{};
    for (var t in transactions.where(
      (t) => t.type == TransactionTypeModel.expense,
    )) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    for (var entry in categoryTotals.entries) {
      rows.add([_getCategoryName(entry.key), entry.value]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'relatorio_equily_${DateTime.now().millisecondsSinceEpoch}.xls';
    final file = File('${output.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }
}
