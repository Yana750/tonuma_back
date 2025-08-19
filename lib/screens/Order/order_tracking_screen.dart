// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:tonuma_shop/widgets/constants.dart';
// import 'package:tonuma_shop/screens/nav_bar_screen.dart';
// import 'package:tonuma_shop/widgets/gradient_button.dart';
// import '../../models/delivery_model.dart';
// import 'order_screen.dart';
//
// class OrderTrackingScreen extends StatelessWidget {
//   final OrderData order;
//
//   OrderTrackingScreen({super.key, required this.order});
//
//   final List<String> statusOrder = [
//     "ожидание",
//     "в обработке",
//     "собран",
//     "отправлен",
//     "подтверждение",
//     "получен",
//   ];
//
//   List<DeliveryStep> getTimelineSteps() {
//     final currentIndex = statusOrder.indexOf(order.currentStatus.toLowerCase());
//
//     return List.generate(statusOrder.length, (index) {
//       final status = statusOrder[index];
//       final stepDate = order.statusDates[status];
//       return DeliveryStep(
//         status: status.capitalize(),
//         date: _formatDate(stepDate),
//         isCompleted: index <= currentIndex,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final timelineSteps = getTimelineSteps();
//
//     final estimatedDeliveryDate = order.createdAt.add(Duration(days: 5 + Random().nextInt(3)));
//     final formattedEstimatedDate = DateFormat("d MMMM", "ru").format(estimatedDeliveryDate);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             foregroundColor: Colors.white,
//             pinned: true,
//             expandedHeight: 120,
//             backgroundColor: Colors.transparent,
//             flexibleSpace: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: grimaryColor,
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: FlexibleSpaceBar(
//                 title: Text(
//                   "Информация о доставке",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 // Дата доставки
//                 Container(
//                   width: double.infinity,
//                   margin: EdgeInsets.all(16),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         "Предполагаемая доставки",
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                       SizedBox(height: 5),
//                       Text(
//                         formattedEstimatedDate,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.deepOrange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           order.currentStatus.capitalize(),
//                           style: TextStyle(
//                             color: Colors.deepOrange,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 2),
//                 if (order.currentStatus.toLowerCase() == "подтверждение")
//                   Container(
//                     margin: EdgeInsets.all(16),
//                     padding: EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           "Покажите QR-код водителю для получения заказа",
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: 16),
//                         QrImageView(
//                           data: order.id, // можно зашифровать что угодно: id, JSON, токен
//                           version: QrVersions.auto,
//                           size: 200.0,
//                         ),
//                       ],
//                     ),
//                   ),
//                 // Таймлайн
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: 16),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: List.generate(timelineSteps.length, (index) {
//                       final step = timelineSteps[index];
//                       return _buildTimelineItem(
//                         status: step.status,
//                         date: step.date,
//                         isCompleted: step.isCompleted,
//                         isFirst: index == 0,
//                         isLast: index == timelineSteps.length - 1,
//                       );
//                     }),
//                   ),
//                 ),
//                 // Детали
//                 SizedBox(height: 16),
//                 Container(
//                   margin: EdgeInsets.symmetric(horizontal: 16),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Детали доставки",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           IconBox(icon: Icons.local_shipping_outlined),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: InfoTile(
//                               title: "Номер заказа",
//                               value: order.id,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () {},
//                             icon: Icon(Icons.copy, color: Colors.orange),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                       Divider(),
//                       SizedBox(height: 16),
//                       Row(
//                         children: [
//                           IconBox(icon: Icons.location_on_outlined),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: InfoTile(
//                               title: "Адрес доставки",
//                               value: order.address,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomSheet: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black45.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, -5),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BottomNavBar(initialIndex: 4),
//                       ),
//                     );
//                   },
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     side: BorderSide(color: Colors.orange),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text("Домой", style: TextStyle(color: Colors.black)),
//                 ),
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: GradientButton(
//                   text: "Показать детали заказа",
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => CheckoutPage()),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTimelineItem({
//     required String status,
//     required String date,
//     required bool isCompleted,
//     bool isFirst = false,
//     bool isLast = false,
//   }) {
//     return IntrinsicHeight(
//       child: Row(
//         children: [
//           SizedBox(
//             width: 60,
//             child: Column(
//               children: [
//                 if (!isFirst)
//                   Container(
//                     width: 2,
//                     height: 30,
//                     color: Colors.grey.shade300,
//                   ),
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isCompleted ? Colors.orange : Colors.white,
//                     border: Border.all(
//                       width: 2,
//                       color: isCompleted ? Colors.orange : Colors.black,
//                     ),
//                   ),
//                   child: isCompleted
//                       ? Icon(Icons.check, size: 18, color: Colors.white)
//                       : null,
//                 ),
//                 if (!isLast)
//                   Container(
//                     width: 2,
//                     height: 30,
//                     color: isCompleted
//                         ? Colors.orange
//                         : Colors.black.withOpacity(0.2),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Container(
//               margin: EdgeInsets.only(left: 8, bottom: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     status,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                       color: isCompleted ? Colors.orange : Colors.black,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     date,
//                     style: TextStyle(fontSize: 12, color: Colors.black),
//                   ),
//                   SizedBox(height: 4),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   String _formatDate(dynamic date) {
//     if (date == null) return '-';
//     try {
//       DateTime parsedDate;
//       if (date is DateTime) {
//         parsedDate = date;
//       } else if (date is String) {
//         parsedDate = DateTime.parse(date);
//       } else {
//         return '-';
//       }
//       return DateFormat('dd.MM.yyyy').format(parsedDate);
//     } catch (e) {
//       return '-';
//     }
//   }
// }
//
// class IconBox extends StatelessWidget {
//   final IconData icon;
//
//   const IconBox({super.key, required this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: kprimaryColor?.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(icon, color: Colors.orange),
//     );
//   }
// }
//
// class InfoTile extends StatelessWidget {
//   final String title;
//   final String value;
//
//   const InfoTile({super.key, required this.title, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: TextStyle(fontSize: 14, color: Colors.black45)),
//         SizedBox(height: 4),
//         Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
// }