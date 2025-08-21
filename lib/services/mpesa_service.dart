import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class MpesaService {
  final String _consumerKey = dotenv.env['MPESA_CONSUMER_KEY']!;
  final String _consumerSecret = dotenv.env['MPESA_CONSUMER_SECRET']!;
  final String _shortCode = dotenv.env['MPESA_SHORTCODE']!;
  final String _passkey = dotenv.env['MPESA_PASSKEY']!;
  final String _callbackUrl = dotenv.env['MPESA_CALLBACK_URL']!;
  final String _stkPushUrl = 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest';
  final String _tokenUrl = 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';

  Future<String> _getAccessToken() async {
    final basicAuth = base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));

    final response = await http.get(
      Uri.parse(_tokenUrl),
      headers: {
        'Authorization': 'Basic $basicAuth',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to get M-Pesa access token: ${response.body}');
    }
  }

  Future<bool> initiateStkPush({
    required String phoneNumber,
    required int amount,
    required String description,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      final password = base64Encode(utf8.encode('$_shortCode$_passkey$timestamp'));

      final body = {
        'BusinessShortCode': _shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount,
        'PartyA': phoneNumber,
        'PartyB': _shortCode,
        'PhoneNumber': phoneNumber,
        'CallBackURL': _callbackUrl,
        'AccountReference': 'SoraAppPayment',
        'TransactionDesc': description,
      };

      final response = await http.post(
        Uri.parse(_stkPushUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);
      print('M-Pesa STK Push Response: $responseData');

      if (response.statusCode == 200 && responseData['ResponseCode'] == '0') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error initiating M-Pesa STK Push: $e');
      return false;
    }
  }
}