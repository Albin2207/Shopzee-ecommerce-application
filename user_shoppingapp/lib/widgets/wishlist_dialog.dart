// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:user_shoppingapp/controllers/database_service.dart';
// import 'package:user_shoppingapp/provider/wishlist_provider.dart';

// class WishlistSelectionDialog extends StatelessWidget {
//   final String productId;

//   const WishlistSelectionDialog({
//     super.key,
//     required this.productId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Save to Wishlist',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             Consumer<WishlistProvider>(
//               builder: (context, wishlistProvider, _) {
//                 return StreamBuilder<QuerySnapshot>(
//                   stream: DbService().readWishlistCollections(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }

//                     final collections = snapshot.data?.docs ?? [];

//                     return Container(
//                       constraints: BoxConstraints(maxHeight: 300),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Default Wishlist option with checkbox
//                             CheckboxListTile(
//                               secondary: Icon(
//                                 wishlistProvider.isWishlistedInCollection(productId, 'default')
//                                     ? Icons.favorite
//                                     : Icons.favorite_border,
//                                 color: wishlistProvider.isWishlistedInCollection(productId, 'default')
//                                     ? Colors.red
//                                     : null,
//                               ),
//                               title: Text('Default Wishlist'),
//                               value: wishlistProvider.isWishlistedInCollection(productId, 'default'),
//                               onChanged: (bool? value) async {
//                                 await wishlistProvider.toggleWishlist(
//                                   productId,
//                                   'default',
//                                 );
//                               },
//                             ),
//                             Divider(),
//                             ...collections.map((doc) {
//                               final data = doc.data() as Map<String, dynamic>;
//                               return CheckboxListTile(
//                                 secondary: Icon(
//                                   wishlistProvider.isWishlistedInCollection(productId, doc.id)
//                                       ? Icons.favorite
//                                       : Icons.favorite_border,
//                                   color: wishlistProvider.isWishlistedInCollection(productId, doc.id)
//                                       ? Colors.red
//                                       : null,
//                                 ),
//                                 title: Text(data['name'] ?? 'Untitled'),
//                                 subtitle: data['description'] != null
//                                     ? Text(data['description'])
//                                     : null,
//                                 value: wishlistProvider.isWishlistedInCollection(productId, doc.id),
//                                 onChanged: (bool? value) async {
//                                   await wishlistProvider.toggleWishlist(
//                                     productId,
//                                     doc.id,
//                                   );
//                                 },
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Done'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => _CreateWishlistDialog(productId: productId),
//                     );
//                   },
//                   child: Text('Create New Wishlist'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CreateWishlistDialog extends StatefulWidget {
//   final String productId;

//   const _CreateWishlistDialog({
//     required this.productId,
//   });

//   @override
//   State<_CreateWishlistDialog> createState() => _CreateWishlistDialogState();
// }

// class _CreateWishlistDialogState extends State<_CreateWishlistDialog> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Create New Wishlist',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Wishlist Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: 'Description (Optional)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Cancel'),
//                 ),
//                 SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (_nameController.text.isNotEmpty) {
//                       await context.read<WishlistProvider>().createWishlistCollection(
//                             _nameController.text,
//                             description: _descriptionController.text.isEmpty
//                                 ? null
//                                 : _descriptionController.text,
//                           );
//                       if (context.mounted) {
//                         Navigator.pop(context); // Close create dialog
//                       }
//                     }
//                   },
//                   child: Text('Create'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }