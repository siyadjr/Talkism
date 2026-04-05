// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/call_model.dart';

// class WebhookService {
//   final String webhookUrl = "https://your-cloud-function-url.com/call-events";

//   Future<void> triggerCallEvent(String eventType, CallModel call) async {
//     try {
//       final response = await http.post(
//         Uri.parse(webhookUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'eventType': eventType,
//           'call': call.toMap(),
//         }),
//       );
//       if (response.statusCode != 200) {
//         print("Webhook failed: ${response.body}");
//       }
//     } catch (e) {
//       print("Webhook error: $e");
//     }
//   }
// }
