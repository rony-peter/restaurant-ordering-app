import 'dart:js_interop';

@JS('Razorpay')
extension type RazorpayJS._(JSObject _) implements JSObject {
  external factory RazorpayJS(JSObject options);
  external void open();
}

void openRazorpayWebCheckout({
  required String keyId,
  required String razorpayOrderId,
  required int amount,
  required String currency,
  required String restaurantName,
  required Function(String paymentId) onSuccess,
  required Function() onFailure,
  String contact = '9999999999',
  String email = 'customer@restaurant.com',
}) {
  final options = {
    'key': keyId,
    'amount': amount,
    'currency': currency,
    'name': restaurantName,
    'description': 'Table Order Payment',
    'order_id': razorpayOrderId,
    'prefill': {
      'contact': contact,
      'email': email,
    },
    'theme': {
      'color': '#1E40AF',
    },
    'handler': ((JSObject response) {
      final payId = (response as dynamic).razorpay_payment_id as String?;
      if (payId != null) {
        onSuccess(payId);
      } else {
        onFailure();
      }
    }).toJS,
    'modal': {
      'ondismiss': (() {
        onFailure();
      }).toJS
    }
  }.jsify() as JSObject;

  final razorpay = RazorpayJS(options);
  razorpay.open();
}