import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/payment_detail.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';

class CheckoutDialog extends StatelessWidget {
  final Cart cart;
  final ValueNotifier<TenderType> selectedTenderNotifier;
  final TextEditingController cashReceivedController;
  final TextEditingController customerPhoneController;
  final TextEditingController customerNameController;
  final ValueNotifier<List<PaymentDetail>> splitPaymentsNotifier;
  final ValueNotifier<Customer?> selectedCustomerNotifier;

  const CheckoutDialog._({
    super.key,
    required this.cart,
    required this.selectedTenderNotifier,
    required this.cashReceivedController,
    required this.customerPhoneController,
    required this.customerNameController,
    required this.splitPaymentsNotifier,
    required this.selectedCustomerNotifier,
  });

  factory CheckoutDialog({
    Key? key,
    required Cart cart,
    String? initialCustomerPhone,
  }) {
    return CheckoutDialog._(
      key: key,
      cart: cart,
      selectedTenderNotifier: ValueNotifier<TenderType>(TenderType.cash),
      cashReceivedController: TextEditingController(
        text: cart.grandTotal.toStringAsFixed(2),
      ),
      customerPhoneController: TextEditingController(
        text: initialCustomerPhone ?? '',
      ),
      customerNameController: TextEditingController(),
      splitPaymentsNotifier: ValueNotifier<List<PaymentDetail>>([]),
      selectedCustomerNotifier: ValueNotifier<Customer?>(null),
    );
  }

  void _setCashPreset(double amount) {
    cashReceivedController.text = amount.toStringAsFixed(2);
  }

  void _addSplitPayment(TenderType type, double amount) {
    if (amount <= 0) return;
    final currentList = List<PaymentDetail>.from(splitPaymentsNotifier.value);
    currentList.add(PaymentDetail(tenderType: type, amount: amount));
    splitPaymentsNotifier.value = currentList;
  }

  void _removeSplitPayment(int index) {
    final currentList = List<PaymentDetail>.from(splitPaymentsNotifier.value);
    currentList.removeAt(index);
    splitPaymentsNotifier.value = currentList;
  }

  void _submitCheckout(BuildContext context) {
    final tender = selectedTenderNotifier.value;
    final splitList = splitPaymentsNotifier.value;
    final phone = customerPhoneController.text.trim();
    final name = customerNameController.text.trim();
    final selectedCustomer = selectedCustomerNotifier.value;

    List<PaymentDetail> payments = [];
    double changeGiven = 0.0;

    if (splitList.isNotEmpty) {
      final totalSplit = splitList.fold(0.0, (sum, p) => sum + p.amount);
      if (totalSplit < cart.grandTotal && (cart.grandTotal - totalSplit) > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Total split payments (${CurrencyFormatter.format(totalSplit)}) is less than total due (${CurrencyFormatter.format(cart.grandTotal)}).',
            ),
          ),
        );
        return;
      }
      payments = splitList;
      changeGiven = (totalSplit - cart.grandTotal).clamp(0.0, 99999.0);
    } else {
      // Single Tender
      if (tender == TenderType.cash) {
        final rec = double.tryParse(cashReceivedController.text.trim()) ?? 0.0;
        if (rec < cart.grandTotal) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Received cash is less than total due.')),
          );
          return;
        }
        changeGiven = rec - cart.grandTotal;
        payments = [PaymentDetail(tenderType: TenderType.cash, amount: rec)];
      } else if (tender == TenderType.customerAccount) {
        if (selectedCustomer == null && phone.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select or specify a customer account to charge.')),
          );
          return;
        }
        payments = [
          PaymentDetail(tenderType: TenderType.customerAccount, amount: cart.grandTotal),
        ];

        // Charge debt to customer via CustomerBloc
        if (selectedCustomer != null) {
          try {
            context.read<CustomerBloc>().add(
                  ChargeDebtEvent(
                    customerId: selectedCustomer.id,
                    amount: cart.grandTotal,
                    notes: 'POS Account Sale',
                  ),
                );
          } catch (_) {}
        }
      } else {
        payments = [
          PaymentDetail(tenderType: tender, amount: cart.grandTotal),
        ];
      }
    }

    final finalCustomerName = selectedCustomer?.name ?? (name.isNotEmpty ? name : null);
    final finalCustomerPhone = selectedCustomer?.phone ?? (phone.isNotEmpty ? phone : null);

    context.read<PosBloc>().add(
          ProcessCheckoutEvent(
            payments: payments,
            customerPhone: finalCustomerPhone,
            customerName: finalCustomerName,
            changeGiven: changeGiven,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space24),
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header & Total Due Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.circleDollarSign,
                        color: AppColors.success,
                        size: 22,
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      Text(
                        'Payment & Checkout',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppDimensions.space12),

              // Total Due Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL AMOUNT DUE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(cart.grandTotal),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${cart.totalItemCount} items',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        if (cart.discountAmount > 0)
                          Text(
                            'Saved: ${CurrencyFormatter.format(cart.discountAmount)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Text(
                          'Incl. 14% VAT: ${CurrencyFormatter.format(cart.taxAmount)}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // 2. Tender Selection
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 8),

              ValueListenableBuilder<TenderType>(
                valueListenable: selectedTenderNotifier,
                builder: (context, currentTender, _) {
                  return ValueListenableBuilder<List<PaymentDetail>>(
                    valueListenable: splitPaymentsNotifier,
                    builder: (context, splitList, _) {
                      final isSplitActive = splitList.isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _TenderChip(
                                  label: 'Cash',
                                  icon: LucideIcons.banknote,
                                  isSelected: currentTender == TenderType.cash && !isSplitActive,
                                  color: AppColors.tenderCash,
                                  onTap: () {
                                    splitPaymentsNotifier.value = [];
                                    selectedTenderNotifier.value = TenderType.cash;
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TenderChip(
                                  label: 'Card',
                                  icon: LucideIcons.creditCard,
                                  isSelected: currentTender == TenderType.card && !isSplitActive,
                                  color: AppColors.tenderCard,
                                  onTap: () {
                                    splitPaymentsNotifier.value = [];
                                    selectedTenderNotifier.value = TenderType.card;
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TenderChip(
                                  label: 'Instapay',
                                  icon: LucideIcons.qrCode,
                                  isSelected: currentTender == TenderType.instapay && !isSplitActive,
                                  color: AppColors.tenderInstapay,
                                  onTap: () {
                                    splitPaymentsNotifier.value = [];
                                    selectedTenderNotifier.value = TenderType.instapay;
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TenderChip(
                                  label: 'Vodafone Cash',
                                  icon: LucideIcons.smartphone,
                                  isSelected: currentTender == TenderType.vodafoneCash && !isSplitActive,
                                  color: AppColors.tenderVodafone,
                                  onTap: () {
                                    splitPaymentsNotifier.value = [];
                                    selectedTenderNotifier.value = TenderType.vodafoneCash;
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TenderChip(
                                  label: 'Customer Account / Tab',
                                  icon: LucideIcons.bookUser,
                                  isSelected: currentTender == TenderType.customerAccount && !isSplitActive,
                                  color: AppColors.warning,
                                  onTap: () {
                                    splitPaymentsNotifier.value = [];
                                    selectedTenderNotifier.value = TenderType.customerAccount;
                                  },
                                ),
                                const SizedBox(width: 8),
                                _TenderChip(
                                  label: 'Split Tender',
                                  icon: LucideIcons.split,
                                  isSelected: isSplitActive,
                                  color: AppColors.accent,
                                  onTap: () {
                                    if (splitList.isEmpty) {
                                      final half = (cart.grandTotal / 2);
                                      splitPaymentsNotifier.value = [
                                        PaymentDetail(tenderType: TenderType.cash, amount: half),
                                        PaymentDetail(tenderType: TenderType.card, amount: cart.grandTotal - half),
                                      ];
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),

                          // 3. Conditional Tender Pane
                          if (isSplitActive)
                            _buildSplitTenderPane(context, splitList)
                          else if (currentTender == TenderType.cash)
                            _buildCashPane(context)
                          else if (currentTender == TenderType.customerAccount)
                            _buildCustomerAccountPane(context)
                          else
                            _buildDigitalTenderPane(context, currentTender),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // 4. Customer Phone / Name (Loyalty)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Phone (Loyalty / Receipt)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: customerPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '01xxxxxxxxx',
                            prefixIcon: Icon(LucideIcons.phone, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Name (Optional)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: customerNameController,
                          decoration: const InputDecoration(
                            hintText: 'Walk-in Guest',
                            prefixIcon: Icon(LucideIcons.user, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),

              // 5. Submit Checkout Action
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  onPressed: () => _submitCheckout(context),
                  icon: const Icon(LucideIcons.checkCheck, size: 18),
                  label: const Text(
                    'COMPLETE TRANSACTION & PRINT',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerAccountPane(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        List<Customer> customers = [];
        if (state is CustomersLoaded) {
          customers = state.allCustomers;
        }

        return ValueListenableBuilder<Customer?>(
          valueListenable: selectedCustomerNotifier,
          builder: (context, selectedCustomer, _) {
            return Container(
              padding: const EdgeInsets.all(AppDimensions.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.bookUser, size: 18, color: AppColors.warning),
                      const SizedBox(width: 8),
                      const Text(
                        'Charge to Customer Store Credit / Tab',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Customer Dropdown Picker
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceDark,
                        hint: const Text(
                          '-- Select Customer Account to Charge --',
                          style: TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                        ),
                        value: selectedCustomer?.id,
                        items: customers.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(
                              '${c.name} (${c.phone}) — Current Debt: ${CurrencyFormatter.format(c.totalDebt)}',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          );
                        }).toList(),
                        onChanged: (customerId) {
                          if (customerId != null) {
                            final chosen = customers.firstWhere((c) => c.id == customerId);
                            selectedCustomerNotifier.value = chosen;
                            customerNameController.text = chosen.name;
                            customerPhoneController.text = chosen.phone;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (selectedCustomer != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Debt: ${CurrencyFormatter.format(selectedCustomer.totalDebt)}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryDark),
                          ),
                          Text(
                            'New Balance: ${CurrencyFormatter.format(selectedCustomer.totalDebt + cart.grandTotal)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.danger,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCashPane(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cash Received (EGP)',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: cashReceivedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(LucideIcons.banknote, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Cash Quick Preset Buttons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _CashPresetBtn(
                label: 'Exact (${cart.grandTotal.toStringAsFixed(2)})',
                onTap: () => _setCashPreset(cart.grandTotal),
              ),
              _CashPresetBtn(label: '50', onTap: () => _setCashPreset(50)),
              _CashPresetBtn(label: '100', onTap: () => _setCashPreset(100)),
              _CashPresetBtn(label: '200', onTap: () => _setCashPreset(200)),
              _CashPresetBtn(label: '500', onTap: () => _setCashPreset(500)),
              _CashPresetBtn(label: '1000', onTap: () => _setCashPreset(1000)),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Live Change / Remaining Balance Calculation
          AnimatedBuilder(
            animation: cashReceivedController,
            builder: (context, _) {
              final rec = double.tryParse(cashReceivedController.text.trim()) ?? 0.0;
              final diff = rec - cart.grandTotal;

              if (diff >= 0) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.success),
                          SizedBox(width: 6),
                          Text(
                            'Payment Status: Fully Paid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Change Due: ${CurrencyFormatter.format(diff)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                final remaining = -diff;
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.alertCircle, size: 16, color: AppColors.warning),
                          SizedBox(width: 6),
                          Text(
                            'Payment Status: Partially Paid',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Remaining Balance: ${CurrencyFormatter.format(remaining)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.warning,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalTenderPane(BuildContext context, TenderType tender) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(LucideIcons.terminal, size: 24, color: AppColors.primaryLight),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Present POS Terminal / QR for Payment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customer will pay ${CurrencyFormatter.format(cart.grandTotal)} via ${tender.name.toUpperCase()}.',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTenderPane(BuildContext context, List<PaymentDetail> splitList) {
    final totalSplit = splitList.fold(0.0, (sum, p) => sum + p.amount);
    final remaining = (cart.grandTotal - totalSplit).clamp(0.0, 99999.0);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Split Tender Entries',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'Remaining: ${CurrencyFormatter.format(remaining)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: remaining > 0 ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...splitList.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.tenderName,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      CurrencyFormatter.format(item.amount),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 14, color: AppColors.danger),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeSplitPayment(idx),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              _SplitAddBtn(
                label: '+ Cash',
                onTap: () => _addSplitPayment(TenderType.cash, remaining > 0 ? remaining : 50.0),
              ),
              const SizedBox(width: 6),
              _SplitAddBtn(
                label: '+ Card',
                onTap: () => _addSplitPayment(TenderType.card, remaining > 0 ? remaining : 50.0),
              ),
              const SizedBox(width: 6),
              _SplitAddBtn(
                label: '+ Instapay',
                onTap: () => _addSplitPayment(TenderType.instapay, remaining > 0 ? remaining : 50.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? color : AppColors.borderDark,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? color : AppColors.textMutedDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashPresetBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CashPresetBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: const BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _SplitAddBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SplitAddBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceDark,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 10.5)),
    );
  }
}
