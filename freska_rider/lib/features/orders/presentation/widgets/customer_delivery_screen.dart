import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/theme/stitch_typography.dart';
import '../../domain/entities/active_order_entity.dart';
import '../cubit/order_lifecycle_bloc.dart';
import '../cubit/order_lifecycle_event.dart';
import '../cubit/order_lifecycle_state.dart';
import '../cubit/voice_navigation_cubit.dart';
import 'voice_navigation_button.dart';
import '../../../../shared/widgets/sliders/swipe_action_button.dart';

class CustomerDeliveryScreen extends StatefulWidget {
  final ActiveOrderEntity order;
  final String? customerFullAddress;
  final String? customerPhone;

  const CustomerDeliveryScreen({
    super.key,
    required this.order,
    this.customerFullAddress,
    this.customerPhone,
  });

  @override
  State<CustomerDeliveryScreen> createState() => _CustomerDeliveryScreenState();
}

class _CustomerDeliveryScreenState extends State<CustomerDeliveryScreen> {
  bool _hasArrivedAtCustomer = false;
  bool _isCodCollected = false;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VoiceNavigationCubit>().startNavigation(
              destinationName: widget.order.customer.name,
              targetLat: widget.order.customer.deliveryLatitude,
              targetLng: widget.order.customer.deliveryLongitude,
            );
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _callCustomer() async {
    final phone = widget.customerPhone ?? widget.order.customer.phone;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchGoogleMaps() async {
    final lat = widget.order.customer.deliveryLatitude;
    final lng = widget.order.customer.deliveryLongitude;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onMarkArrived(OrderLifecycleBloc bloc) {
    HapticFeedback.mediumImpact();
    context.read<VoiceNavigationCubit>().announceArrival();
    bloc.add(MarkArrivedAtCustomerEvent(
      orderId: widget.order.id,
      latitude: widget.order.customer.deliveryLatitude,
      longitude: widget.order.customer.deliveryLongitude,
    ));
  }

  void _onSwipeCompleteDelivery(OrderLifecycleBloc bloc) {
    HapticFeedback.heavyImpact();
    bloc.add(ConfirmDeliveryEvent(
      orderId: widget.order.id,
      otp: _otpController.text.trim().isNotEmpty ? _otpController.text.trim() : '0000',
      latitude: widget.order.customer.deliveryLatitude,
      longitude: widget.order.customer.deliveryLongitude,
    ));
  }

  void _showDeliveryCompletedDialog(DeliveryConfirmed state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: StitchColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: StitchColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: StitchColors.primaryLight, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delivery Complete!', style: StitchTypography.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${widget.order.orderNumber} successfully delivered.',
                style: StitchTypography.bodyMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StitchColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: StitchColors.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Earnings Credited', style: StitchTypography.bodyMedium),
                  Text(
                    '₹${state.earningsCredited > 0 ? state.earningsCredited.toStringAsFixed(2) : widget.order.totalRiderPayout.toStringAsFixed(2)}',
                    style: StitchTypography.titleLarge.copyWith(
                      color: StitchColors.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/dashboard');
              },
              child: const Text('Back to Dashboard', style: StitchTypography.buttonText),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCod = widget.order.paymentMode.toLowerCase() == 'cod' || widget.order.codAmount > 0;
    final address = widget.customerFullAddress ?? widget.order.customer.deliveryAddress;
    final phone = widget.customerPhone ?? widget.order.customer.phone;

    return BlocConsumer<OrderLifecycleBloc, OrderLifecycleState>(
      listener: (context, state) {
        if (state is ArrivedAtCustomerSuccess) {
          setState(() => _hasArrivedAtCustomer = true);
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arrival at customer confirmed. Collect payment if COD & hand over.'),
              backgroundColor: StitchColors.primary,
            ),
          );
        } else if (state is DeliveryConfirmed) {
          _showDeliveryCompletedDialog(state);
        } else if (state is OrderLifecycleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: StitchColors.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<OrderLifecycleBloc>();
        final isLoading = state is OrderLifecycleLoading;

        return Scaffold(
          backgroundColor: StitchColors.background,
          appBar: AppBar(
            backgroundColor: StitchColors.surface,
            elevation: 0,
            title: Text(
              'Deliver #${widget.order.orderNumber}',
              style: StitchTypography.titleMedium,
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(
                  child: VoiceNavigationButton(compact: true),
                ),
              ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StitchColors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Customer Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: StitchColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StitchColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: StitchColors.primaryDark.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_pin_circle_rounded,
                              color: StitchColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.order.customer.name, style: StitchTypography.titleMedium),
                              Text(phone,
                                  style: StitchTypography.labelSmall
                                      .copyWith(color: StitchColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _callCustomer,
                          style: IconButton.styleFrom(
                            backgroundColor: StitchColors.primaryDark.withValues(alpha: 0.3),
                          ),
                          icon: const Icon(Icons.phone_rounded, color: StitchColors.primaryLight),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: StitchColors.surfaceBorder),
                    Text(address, style: StitchTypography.bodyMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _launchGoogleMaps,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: StitchColors.primaryLight,
                              side: const BorderSide(color: StitchColors.primaryLight),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.navigation_rounded, size: 18),
                            label: const Text('Google Maps'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // COD / Payment Badge
              if (isCod)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StitchColors.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StitchColors.accentGold.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.payments_rounded, color: StitchColors.accentGold, size: 22),
                              SizedBox(width: 8),
                              Text('Cash on Delivery (COD)',
                                  style: TextStyle(
                                      color: StitchColors.accentGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                          Text(
                            '₹${widget.order.codAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: StitchColors.accentGold,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: _isCodCollected,
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'I have collected the exact cash amount from customer',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        activeColor: StitchColors.accentGold,
                        onChanged: (v) => setState(() => _isCodCollected = v ?? false),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: StitchColors.primaryDark.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StitchColors.primaryDark),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: StitchColors.primaryLight, size: 18),
                      SizedBox(width: 8),
                      Text('Prepaid Order — Do NOT collect cash from customer',
                          style: TextStyle(color: StitchColors.primaryLight, fontSize: 13)),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Customer Delivery OTP (Optional / Required depending on store policy)
              if (_hasArrivedAtCustomer)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StitchColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StitchColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery Confirmation Code', style: StitchTypography.titleSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter 4 or 6-digit Customer OTP (Optional)',
                          prefixIcon: Icon(Icons.pin_rounded, color: StitchColors.primaryLight),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Action Buttons
              if (!_hasArrivedAtCustomer)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _onMarkArrived(bloc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_rounded),
                              SizedBox(width: 8),
                              Text('Mark Arrived at Customer', style: StitchTypography.labelLarge),
                            ],
                          ),
                  ),
                )
              else
                SwipeActionButton(
                  label: 'Swipe to Complete Delivery',
                  activeColor: StitchColors.primary,
                  enabled: (!isCod || _isCodCollected) && !isLoading,
                  isLoading: isLoading,
                  onSwipeComplete: () => _onSwipeCompleteDelivery(bloc),
                ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
