import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String thumbnailUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.thumbnailUrl,
    this.quantity = 1,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      title: 'foto wisuda',
      subtitle: 'photoshoot graduation with properti',
      price: 9.99,
      thumbnailUrl: '',
    ),
    CartItem(
      id: '2',
      title: 'photobox',
      subtitle: 'With your someone love make a moment',
      price: 59.99,
      thumbnailUrl: '',
    ),
    CartItem(
      id: '3',
      title: 'foto studio',
      subtitle: 'take a moment with your family',
      price: 59.99,
      thumbnailUrl: '',
    ),
  ];

  double get totalPrice {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void updateQuantity(String itemId, int newQuantity) {
    setState(() {
      final itemIndex = cartItems.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        if (newQuantity > 0) {
          cartItems[itemIndex].quantity = newQuantity;
        } else {
          cartItems.removeAt(itemIndex);
        }
      }
    });
  }

  void removeItem(String itemId) {
    setState(() {
      cartItems.removeWhere((item) => item.id == itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  cartItems.clear();
                });
              },
              child: Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body:
          cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItem(cartItems[index]);
                      },
                    ),
                  ),
                  _buildBottomSection(),
                ],
              ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some photography services to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(width: 12),
          // Item Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onPressed:
                              () => updateQuantity(item.id, item.quantity - 1),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed:
                              () => updateQuantity(item.id, item.quantity + 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete Button
          IconButton(
            onPressed: () => removeItem(item.id),
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Coupon Section
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle coupon apply
                    },
                    child: Text(
                      'Apply',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${cartItems.length} items)',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    cartItems.isEmpty
                        ? null
                        : () {
                          // Handle checkout
                          _showCheckoutDialog();
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout'),
          content: Text(
            'Proceed to payment for \$${totalPrice.toStringAsFixed(2)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle payment process
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order placed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  cartItems.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
