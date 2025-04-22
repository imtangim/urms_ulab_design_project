// First, let's create the model classes

// models/due.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/models/billing_model.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({
    super.key,
  });

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen>
    with SingleTickerProviderStateMixin {
  late Future<dynamic> billingData;
  late TabController _tabController;
  final currencyFormat = NumberFormat("#,##,###");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    billingData = Scapper.fetchData(
      title: "Billing",
      designatedurl: "https://urms-online.ulab.edu.bd/billing.php",
      cookie: ref.read(sharedPrefProvider).token!,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      final parsedDate = DateFormat('dd-MM-yyyy').parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCurrency(double amount, {bool isNegative = false}) {
    return amount > 0
        ? '৳${currencyFormat.format(amount)}'
        : '৳${currencyFormat.format(amount.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolor.primaryColor,
        title: const Text(
          'Billing Statement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
          future: billingData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                strokeCap: StrokeCap.round,
                color: Appcolor.buttonBackgroundColor,
              ));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.data is FetchFailure) {
              return Center(
                child: Text(
                  'Error: ${(snapshot.data as FetchFailure).message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return Column(
              children: [
                _buildSummaryCard(
                  billingData:
                      (snapshot.data as FetchSuccess).data as BillingData,
                ),
                Container(
                  color: Appcolor.primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'DUE HISTORY'),
                      Tab(text: 'PAYMENT HISTORY'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDuesTab(
                        billingData:
                            (snapshot.data as FetchSuccess).data as BillingData,
                      ),
                      _buildPaymentsTab(
                        billingData:
                            (snapshot.data as FetchSuccess).data as BillingData,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      //   color: Appcolor.white,
      //   child: ElevatedButton(
      //     onPressed: () {
      //       // Handle payment action
      //     },
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: Appcolor.buttonBackgroundColor,
      //       foregroundColor: Colors.white,
      //       padding: const EdgeInsets.symmetric(vertical: 15),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //     ),
      //     child: const Text('PAY NOW',
      //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      //   ),
      // ),
    );
  }

  Widget _buildSummaryCard({required BillingData billingData}) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                  'Total Payable',
                  _formatCurrency(billingData.totalPayable),
                  Appcolor.textColor),
              _buildSummaryItem('Total Paid',
                  _formatCurrency(billingData.totalPaid), Colors.green),
              _buildSummaryItem(
                'Balance',
                _formatCurrency(
                  billingData.balance,
                  isNegative: billingData.balance > 0,
                ),
                billingData.balance > 0 ? Appcolor.redColor : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Appcolor.greyLabelColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDuesTab({required BillingData billingData}) {
    return ListView(
      // padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Appcolor.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: Column(
            children: [
              _buildTableHeader(
                ['Date', 'Fee Type', 'Amount', 'Discount', 'Payable'],
                [0.20, 0.28, 0.18, 0.16, 0.18],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: billingData.dues.length,
                itemBuilder: (context, index) {
                  final due = billingData.dues[index];
                  final isDiscount = due.payable < 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.white
                          : Appcolor.fillColor.withOpacity(0.3),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 20,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 6,
                              ),
                              child: Text(
                                _formatDate(due.date),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 28,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              child: Text(
                                due.head,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 18,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              child: Text(
                                _formatCurrency(due.amount.toDouble()),
                                style: const TextStyle(fontSize: 13),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 16,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              child: Text(
                                _formatCurrency(due.discount.toDouble()),
                                style: const TextStyle(fontSize: 13),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 18,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              child: Text(
                                _formatCurrency(due.payable.toDouble()),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDiscount ? Colors.green : null,
                                  fontWeight:
                                      isDiscount ? FontWeight.bold : null,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab({required BillingData billingData}) {
    return ListView(
      children: [
        Card(
          color: Appcolor.white,
          elevation: 0,
          child: Column(
            children: [
              _buildTableHeader(
                ['Date', 'MR No.', 'Amount', 'Details'],
                [0.25, 0.25, 0.25, 0.25],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: billingData.payments.length,
                itemBuilder: (context, index) {
                  final payment = billingData.payments[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.white
                          : Appcolor.fillColor.withOpacity(0.3),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 25,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Text(
                              _formatDate(payment.date),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 25,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Text(
                              payment.mrNo,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 25,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Text(
                              _formatCurrency(payment.amount.toDouble()),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 25,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            child: payment.chequeNo.isNotEmpty
                                ? Text(
                                    'Cheque: ${payment.chequeNo}',
                                    style: const TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  )
                                : const Text(
                                    'Cash Payment',
                                    style: TextStyle(fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(List<String> titles, List<double> flexValues) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Appcolor.primaryColor.withOpacity(0.1),
      ),
      child: Row(
        children: List.generate(
          titles.length,
          (index) => Expanded(
            flex: (flexValues[index] * 100).toInt(),
            child: Text(
              titles[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Appcolor.primaryColor,
                fontSize: 13,
              ),
              textAlign: index > 1 ? TextAlign.right : TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }
}
